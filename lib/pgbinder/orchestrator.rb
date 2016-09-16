require 'pgbinder/orchestrator/configuration'

module PGBinder
  # :nodoc:
  module Orchestrator
    ACTIONS = %i(
      print_info_banner
      print_version
      print_help
      print_local_version
      unset_local_version
      write_local_version
      setup
      execute
    ).freeze

    class << self
      def perform(action)
        action_name = action[:name]
        arguments = action[:value]
        raise ArgumentError, 'Wrong action.' unless ACTIONS.include?(action_name)
        send(action_name, arguments)
      end

      private

      def print_info_banner(*)
        puts(<<-EOS
PGBinder is a PostgreSQL version manager, using Docker.

Use --help for a list of all available commands.
EOS
            )
      end

      def print_version(*)
        puts("PGBinder version #{VERSION}")
      end

      def print_help(*)
        puts(<<-EOS
THIS IS A BETA PROJECT, USE IT AT YOUR OWN RISK.

pgbinder setup
pgbinder local
pgbinder local MAJOR.VERSION
pgbinder local unset
pgbinder <shell_command>
pgbinder help
EOS
            )
      end

      def print_local_version(*)
        local_version = Configuration.read_local
        puts(local_version)
      end

      def unset_local_version(*)
        Configuration.erase_local!
      end

      def write_local_version(major_version)
        local_version = Configuration.write_local(major_version)
        puts(local_version)
      end

      def setup(*)
        require 'pgbinder/orchestrator/questioner'
        require 'pgbinder/orchestrator/scripts/setup'

        return unless Questioner.all_clear?(
          'This will recreate all the binary wrappers if already present.'
        ) { SetupScripts.create_binary_wrappers! }

        return unless Questioner.all_clear?(
          'DANGER: This will recreate all the volumes if already present, YOU MIGHT LOSE ALL THE DATA THERE.'
        ) { SetupScripts.create_volumes! }
      end

      def execute(command)
        require 'pgbinder/orchestrator/docker_gateway'

        local_version = Configuration.read_local

        DockerGateway.execute_for_container(command, local_version)
      end
    end
  end
end
