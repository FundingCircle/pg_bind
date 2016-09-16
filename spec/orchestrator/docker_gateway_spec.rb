require 'spec_helper'
require 'pgbinder/orchestrator/docker_gateway'

describe PGBinder::Orchestrator::DockerGateway do
  context '#execute_for_container' do
    let(:docker_gateway) { double(described_class) }

    let(:command) { 'env'.split }
    let(:version) { '9.4' }

    let(:exports) do
      <<-EOS
PATH=/usr/local/pgbinder/wrappers/postgres-9.4:whatever
DATABASE_URL=postgres://localhost:1337
EOS
    end

    before do
      allow(docker_gateway).to receive(:execute_for_container).with(command, version).and_return(exports)
    end

    let(:subject) { docker_gateway.execute_for_container(command, version) }

    it 'exports PATH and DATABASE_URL' do
      expect(subject).to eq(exports)
    end
  end
end
