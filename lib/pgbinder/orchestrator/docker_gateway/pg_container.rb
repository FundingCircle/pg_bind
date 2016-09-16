module PGBinder
  module Orchestrator
    # :nodoc:
    module DockerGateway
      require 'json'

      # :nodoc:
      # rubocop:disable ClassLength
      # rubocop:disable Style/SpecialGlobalVars
      class PGContainer
        class << self
          def for_version(pg_version)
            new(pg_version)
          end
        end

        attr_reader :pg_version, :public_port

        def initialize(pg_version)
          @pg_version = pg_version
          @image = "postgres:#{pg_version}"
          @name = "pgbinder_#{pg_version}"
          @volume = "#{`echo $HOME`.chomp}/.pgbinder/volumes/#{pg_version.tr('.', '_')}_data"
          @info ||= inspect

          post_init
        end

        private

        attr_reader :info

        def post_init
          return setup unless up?
          discover_public_port
        end

        def setup
          destroy! if broken?

          if exited?
            restart
          else
            run
          end

          allocate_public_port
          wait_for_postgres
        end

        def run
          system(
            <<-EOF
tput sc
printf 'Running container "#{@name}".. (this might take a while if the image was never downloaded)'
docker run --privileged=true -i -t -p #{public_port}:#{PG_PORT} -d --name #{@name} -v #{@volume}:/var/lib/postgresql/data #{@image} \
>> /dev/null 2>&1
tput rc;tput el
EOF
          )
        end

        def status
          return nil unless info
          info['State']['Status'].to_sym
        end

        def running?
          return false unless info
          info['State']['Running']
        end

        def exited?
          status == :exited
        end

        def dead?
          return true unless info
          info['State']['Dead']
        end

        def error
          return '' unless info
          info['State']['Error']
        end

        def down?
          !running?
        end

        def up?
          !down?
        end

        def healthy?
          up? && !dead? && error.to_s.empty?
        end

        def broken?
          !status.nil? && !running? && !exited?
        end

        alias stopped? exited?

        def destroy!
          `docker rm -f #{@name} 2> /dev/null`
          if $?.exitstatus.nonzero?
            raise DockerError, 'Something went wrong while removing container (is Docker running?)'
          end
        end

        def restart
          `docker start #{@name} 2> /dev/null`
          if $?.exitstatus.nonzero?
            raise DockerError, 'Something went wrong while removing container (is Docker running?)'
          end
        end

        def inspect
          results = `docker inspect #{@name} 2> /dev/null`

          JSON.parse(results)[0] if results
        end

        def discover_public_port
          nil unless info
          @public_port ||= info['NetworkSettings']['Ports']["#{PG_PORT}/tcp"][0]['HostPort']
        end

        def allocate_public_port
          require 'socket'

          socket = Socket.new(:INET, :STREAM, 0)
          socket.bind(Addrinfo.tcp('0.0.0.0', 0))
          @public_port = socket.local_address.ip_port

          socket.close
        rescue SystemCallError => error
          raise error if error.class.name.start_with?('Errno::')
        end

        # rubocop:disable Metrics/MethodLength
        def wait_for_postgres
          system(
            <<-EOF
set -e

WAIT_SLEEP=0.5
WAIT_RETRIES=60

WAIT_MSG="Waiting for Postgres to start.."

retries=0

update_loader()
{
  printf "."
  retries=$(($retries + 1))
}

check_pg()
{
  printf "$WAIT_MSG"

  until docker exec #{@name} psql -U postgres -c "\\q" 2> /dev/null; do
    update_loader
    sleep $WAIT_SLEEP

    if [ "$retries" -gt "$WAIT_RETRIES" ]; then
      echo "FAILED"
      printf "Timeout wating for Postgres to start in container \"#{@name}\", command aborted."
      exit 1
    fi
  done
}

erase_loader()
{
  deletions=$((${#WAIT_MSG} + $retries))
  eraser=""
  while [ "${#eraser}" -le "$deletions" ]; do
    printf -v eraser " ${eraser}"
  done
  printf "\r$eraser\r"
}

check_pg
erase_loader
EOF
          )
        end
      end
    end
  end
end
