module PGBinder
  module Orchestrator
    # :nodoc:
    class Configuration
      CONFIG_FILE = '.pg-version'.freeze

      class << self
        def read_local
          new.pg_version
        end

        def write_local(major_version)
          raise ConfigError, 'Invalid postgres version' unless Postgres.valid_version?(major_version)
          new(create_with_version: major_version).pg_version
        end

        def erase_local!
          new.erase!
        end
      end

      attr_reader :pg_version

      def initialize(create_with_version: nil)
        @pg_version = nil

        create_config_file_with_version(create_with_version) if create_with_version
        read_version_from_config_file
      end

      def erase!
        erase_config_file
      end

      private

      def create_config_file_with_version(version)
        File.open(CONFIG_FILE, 'w') { |file| file.write("#{version}\n") }
      end

      def read_version_from_config_file
        raw_config = File.open(CONFIG_FILE, 'r', &:read)
        @pg_version = raw_config.chomp
      rescue Errno::ENOENT, IOError => error
        if error.message =~ /No such file or directory/
          raise ConfigError, "No #{CONFIG_FILE} detected, please create one using: local MAJOR.VERSION"
        end
        raise GenericIOError, "Something went wrong while reading #{CONFIG_FILE}."
      end

      def erase_config_file
        File.delete(CONFIG_FILE)
      rescue Errno::ENOENT, IOError
        raise GenericIOError, "Something went wrong while deleting #{CONFIG_FILE}."
      end
    end
  end
end
