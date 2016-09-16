require 'spec_helper'

describe PGBinder::Orchestrator do
  describe '#perform' do
    context 'with allowed action' do
      let(:action) { { name: :write_local_version, value: '9.4' } }

      it 'performs the correct action' do
        expect(described_class).to receive(:send).with(:write_local_version, '9.4')

        described_class.perform(action)
      end
    end

    context 'with unallowed action' do
      let(:action) { { name: :wrong_action, value: 'whatever' } }

      it 'raises an exception' do
        allow(described_class).to receive(:send).with(:wrong_action, 'whatever')

        expect { described_class.perform(action) }.to raise_error(PGBinder::ArgumentError)
      end
    end
  end
end
