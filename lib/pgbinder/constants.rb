module PGBinder
  PG_PORT = 5432
  PG_DATA = '/var/lib/postgresql/data'.freeze # https://github.com/docker-library/postgres/blob/master/Dockerfile.template#L51
  BASE_PATH = '/usr/local/pgbinder'.freeze
end
