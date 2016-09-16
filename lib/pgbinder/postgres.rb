module PGBinder
  # :nodoc:
  class Postgres
    MAJOR_VERSIONS = %w(8.4 9.0 9.1 9.2 9.3 9.4 9.5).freeze

    class << self
      def valid_version?(version)
        MAJOR_VERSIONS.any? { |major_version| regex_for_version(major_version) =~ version }
      end

      private

      def regex_for_version(version)
        Regexp.new('^' + version.split('').map { |char| "[#{char}]" }.join)
      end
    end
  end
end
