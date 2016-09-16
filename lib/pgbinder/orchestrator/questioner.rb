module PGBinder
  module Orchestrator
    # :nodoc:
    class Questioner
      class << self
        # rubocop:disable Metrics/MethodLength
        def all_clear?(message, &block)
          proceed = false

          Kernel.loop do
            print("#{message} Do you want to proceed? [Yn] ")

            ARGV.clear
            choice = gets.chomp

            if %w(Y y yes).include?(choice)
              yield block
              puts('Done.')
              proceed = true
            elsif %w(N n no).include?(choice)
              puts('Aborted.')
            else
              puts('Wrong choice entered.')
              next
            end
            break
          end

          proceed
        end
      end
    end
  end
end
