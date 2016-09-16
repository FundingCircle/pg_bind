require 'spec_helper'
require 'pgbinder/orchestrator/docker_gateway/pg_container'

describe PGBinder::Orchestrator::DockerGateway::PGContainer do
  let(:pg_version) { '9.4' }

  context 'interface' do
    context '#for_version' do
      let(:subject) { described_class.for_version(pg_version) }

      it 'allocates an object with the provided pg_version' do
        expect(described_class).to receive(:new).with(pg_version)

        subject
      end
    end

    context 'class' do
      let(:subject) { instance_double(described_class, pg_version: pg_version, public_port: 1337) }

      context '#pg_version' do
        it 'returns the correct postgres version' do
          expect(subject.pg_version).to eq(pg_version)
        end
      end

      context '#public_port' do
        it 'returns the correct public port' do
          expect(subject.public_port).to eq(1337)
        end
      end
    end
  end
end
