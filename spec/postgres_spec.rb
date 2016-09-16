require 'spec_helper'

describe PGBinder::Postgres do
  describe '#valid_version?' do
    let(:subject) { described_class.valid_version?(version) }

    context 'when version is valid' do
      let(:version) { '9.4' }

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'when version is invalid' do
      let(:version) { '19.4' }

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end
end
