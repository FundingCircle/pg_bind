module PGBinder
  module Orchestrator
    # :nodoc:
    module DockerGateway
      class << self
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/AbcSize
        def execute_for_container(command, local_version)
          require 'yaml'
          require 'pgbinder/orchestrator/docker_gateway/pg_container'

          @container = PGContainer.for_version(local_version)

          reconstructed_command = command.join(' ')

          # Intercept rake db:* tasks call and excute them for each ENV.
          if reconstructed_command =~ /rake db:/ && !reconstructed_command.include?('RAILS_ENV=')
            begin
              db_config = YAML.load_file('config/database.yml')
              envs = db_config.select { |_env, settings| settings['adapter'] == 'postgresql' }.keys
              (envs - ['default']).each do |env|
                system(export_database_url_and_rebuild_command(database_url, reconstructed_command, env))
              end
              exit
            rescue Errno::ENOENT, IOError
              nil # meh.
            end
          else
            full_command = export_database_url_and_rebuild_command(database_url, reconstructed_command)
            exec(full_command)
          end
        end

        private

        attr_reader :database_url

        def export_database_url_and_rebuild_command(database_url, reconstructed_command, env = nil)
          reconstructed_command = "RAILS_ENV=#{env} #{reconstructed_command}" if env
          bin_path = pgbind_wrappers_path
          <<-EOS
export DATABASE_URL=#{database_url}
export PATH=#{bin_path}:$PATH

#{reconstructed_command}
          EOS
        end

        def pgbind_wrappers_path
          "#{BASE_PATH}/wrappers/postgres-#{pg_version}"
        end

        def pg_version
          @container.pg_version
        end

        def database_url
          port = @container.public_port

          @database_url ||= "postgres://localhost:#{port}"
        end
      end
    end
  end
end
