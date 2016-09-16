require 'spec_helper'
require 'pgbinder/orchestrator/configuration'

describe PGBinder::Orchestrator::Configuration do
  context '#read_local' do
    let(:subject) { described_class.read_local }
    let(:pg_version) { '9.4' }
    let(:configuration) { instance_double(described_class) }

    before do
      allow(configuration).to receive(:pg_version).and_return(pg_version)
    end

    it 'allocates an Orchestrator::Configuration object with the correct version' do
      aggregate_failures do
        expect(described_class).to receive(:new).and_return(configuration)
        expect(subject).to eq(pg_version)
      end
    end
  end

  context '#write_local' do
    let(:subject) { described_class.write_local(pg_version) }

    context 'with valid postgres version given in' do
      let(:pg_version) { '9.4' }
      let(:configuration) { instance_double(described_class) }

      it 'writes version to config file' do
        aggregate_failures do
          expect(described_class)
            .to receive(:new).with(create_with_version: pg_version).and_return(configuration).and_call_original

          expect(File)
            .to receive(:open).with(PGBinder::Orchestrator::Configuration::CONFIG_FILE, 'w').and_return(pg_version)
          expect(File)
            .to receive(:open).with(PGBinder::Orchestrator::Configuration::CONFIG_FILE, 'r').and_return(pg_version)

          expect(subject).to eq(pg_version)
        end
      end
    end

    context 'with invalid postgres version given in' do
      let(:pg_version) { '19.4' }

      it 'raises an exception' do
        expect { subject }.to raise_error(PGBinder::ConfigError)
      end
    end
  end

  context '#erase_local!' do
    let(:subject) { described_class.erase_local! }

    context 'when config file exists' do
      let(:pg_version) { '9.4' }
      let(:configuration) { instance_double(described_class) }

      it 'calls erase!' do
        expect(described_class).to receive(:new).and_return(configuration)
        expect(configuration).to receive(:erase!)

        subject
      end
    end

    context 'when config file does not exist' do
      it 'raises an expection' do
        expect { subject }.to raise_error(PGBinder::ConfigError)
      end
    end
  end
end
