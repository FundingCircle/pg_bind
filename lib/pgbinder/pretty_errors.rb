# :nodoc:
module PGBinder
  # :nodoc:
  module PrettyErrors
    module_function

    def prettify(error)
      case error
      when PermissionError, ConfigError, GenericIOError, DockerError, ArgumentError
        puts(error.message)
      else
        raise error
      end
    end
  end

  def self.with_pretty_errors
    yield
  rescue StandardError => e
    PrettyErrors.prettify(e)
  end
end
