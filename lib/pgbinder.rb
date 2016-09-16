require 'pgbinder/version'
require 'pgbinder/constants'
require 'pgbinder/errors'

require 'pgbinder/postgres'

# :nodoc:
module PGBinder
  autoload :Orchestrator, 'pgbinder/orchestrator'

  class << self
    def run(args = [])
      perform_action(args)
    end

    private

    def perform_action(args)
      action = action_from_args(args)
      Orchestrator.perform(action)
    end

    def action_from_args(args)
      option, value = args

      case option
      when nil then { name: :print_info_banner }
      when '-v', 'version', '--version' then { name: :print_version }
      when '-h', 'help', '--help' then { name: :print_help }
      when 'local' then local_action(value)
      when 'setup' then { name: :setup }
      else
        { name: :execute, value: args }
      end
    end

    def local_action(value)
      if value.nil?
        { name: :print_local_version }
      elsif %w(unset --unset).include?(value)
        { name: :unset_local_version }
      else
        { name: :write_local_version, value: value }
      end
    end
  end
end
