module PGBinder
  ConfigError = Class.new(StandardError)
  GenericIOError = Class.new(StandardError)
  PermissionError = Class.new(StandardError)
  DockerError = Class.new(StandardError)
  ArgumentError = Class.new(StandardError)
end
