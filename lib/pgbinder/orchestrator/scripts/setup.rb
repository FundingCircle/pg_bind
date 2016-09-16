module PGBinder
  module Orchestrator
    # :nodoc:
    # rubocop:disable ClassLength
    class SetupScripts
      class << self
        require 'fileutils'

        PG_BINARIES = %w(
          clusterdb
          createdb
          createlang
          createuser
          dropdb
          droplang
          dropuser
          ecpg
          initdb
          oid2name
          pg_archivecleanup
          pg_basebackup
          pg_config
          pg_controldata
          pg_ctl
          pg_dump
          pg_dumpall
          pg_isready
          pg_receivexlog
          pg_recvlogical
          pg_resetxlog
          pg_restore
          pg_rewind
          pg_standby
          pg_test_fsync
          pg_test_timing
          pg_upgrade
          pg_xlogdump
          pgbench
          pltcl_delmod
          pltcl_listmod
          pltcl_loadmod
          postgres
          postmaster
          psql
          reindexdb
          vacuumdb
          vacuumlo
        ).freeze

        # rubocop:disable Metrics/MethodLength
        def create_binary_wrappers!(pg_versions: Postgres::MAJOR_VERSIONS)
          make_base_dir_if_absent!

          target_wrappers_path = "#{BASE_PATH}/wrappers"
          create_or_overwrite_file!(:dir, target_wrappers_path)

          build_binary_wrappers(pg_versions: pg_versions).each do |pg_version, binary_wrappers|
            target_binary_path = "#{target_wrappers_path}/postgres-#{pg_version}"
            create_or_overwrite_file!(:dir, target_binary_path)

            binary_wrappers.each do |pg_binary, script_content|
              target_script = "#{target_binary_path}/#{pg_binary}"
              create_or_overwrite_file!(:file, target_script, script_content)
              write_execution_permissions(target_script)
            end
          end
        end

        def create_volumes!(pg_versions: Postgres::MAJOR_VERSIONS)
          make_base_volumes_dir_if_absent!

          target_volumes_path = "#{read_base_volumes_path}/volumes"
          create_or_overwrite_file!(:dir, target_volumes_path)

          pg_versions.each do |pg_version|
            target_volume_path = "#{target_volumes_path}/#{pg_version.tr('.', '_')}_data"
            create_or_overwrite_file!(:dir, target_volume_path)
          end
        end

        private

        attr_reader :base_volume_path

        def create_or_overwrite_file!(type = :dir, destination = nil, content = nil)
          raise GenericIOError, 'No destination to write to!' if destination.nil?

          if type == :dir
            FileUtils.remove_dir(destination) if File.exist?(destination)
            Dir.mkdir(destination)
          elsif type == :file
            File.open(destination, 'w') { |file| file.write(content.to_s) }
          else
            raise ArgumentError, 'Wrong file type to write!'
          end
        rescue Errno::ENOENT, Errno::EEXIST, IOError
          raise GenericIOError, "Something went wrong while writing at: #{destination}"
        end

        def read_base_volumes_path
          @base_volume_path ||= "#{`echo $HOME`.chomp}/.pgbinder"
        end

        def make_base_volumes_dir_if_absent!
          Dir.mkdir(read_base_volumes_path) unless base_volumes_dir_exists?
        rescue Errno::ENOENT, Errno::EEXIST, IOError
          raise GenericIOError, "Something went wrong while writing at #{read_base_volumes_path}"
        end

        def base_dir_exists?
          File.exist?(BASE_PATH)
        end

        def base_volumes_dir_exists?
          File.exist?(read_base_volumes_path)
        end

        def make_base_dir_if_absent!
          Dir.mkdir(BASE_PATH) unless base_dir_exists?
        end

        def write_execution_permissions(destination)
          FileUtils.chmod('u=wrx,go=rx', destination)
        rescue Errno::ENOENT, IOError
          raise PermissionError, "Cannot set permissions #{permissions} on #{file}"
        end

        def build_binary_wrappers(pg_versions: Postgres::MAJOR_VERSIONS)
          pg_versions.map do |pg_version|
            [
              pg_version,
              PG_BINARIES.map do |pg_binary|
                [
                  pg_binary,
                  case pg_binary
                  when 'psql'
                    <<-EOF
  #!/bin/sh
  if [[ "$@" == *-c* ]]; then
  docker exec -i pgbinder_#{pg_version} #{pg_binary} -U postgres "$@"
  else
  docker exec -it pgbinder_#{pg_version} #{pg_binary} -U postgres "$@"
  fi
  EOF
                  when 'pg_restore'
                    <<-EOF
  #!/bin/sh
  if [[ -n "$@" ]]; then
  IFS=':'; argsArray=($@); unset IFS;
  argsLength=${#argsArray[@]}

  if [[ "$argsLength" -gt "2" ]]
  then
    inputFile=${argsArray[${argsLength}-1]}
    previousArg=${argsArray[${argsLength}-2]}

    if [[ ! "$previousArg" == -* ]]
    then
      # definitely a file has been given as input, eventually.
      options=${@:1:$#-1}
      cat "$inputFile" | docker exec -i pgbinder_#{pg_version} #{pg_binary} -U postgres $options
      exit 0
    fi
  fi

  docker exec -i pgbinder_#{pg_version} #{pg_binary} -U postgres "$@"
  else
  docker exec -it pgbinder_#{pg_version} #{pg_binary} -U postgres "$@"
  fi
  EOF
                  else
                    <<-EOF
  #!/bin/sh
  docker exec -i pgbinder_#{pg_version} #{pg_binary} -U postgres "$@"
  EOF
                  end
                ]
              end
            ]
          end
        end
      end
    end
  end
end
