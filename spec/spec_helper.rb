$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pgbinder'

RSpec.configure do |config|
  config.before :each do
    allow(STDOUT).to receive(:puts) # shut up
  end
end
