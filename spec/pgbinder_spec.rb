require 'spec_helper'

describe PGBinder do
  it 'has a version number' do
    expect(PGBinder::VERSION).not_to be nil
  end

  describe '#run' do
    shared_examples :runs_from_args do |action_name|
      let(:expected_action) { { name: action_name.to_sym } }

      it "performs action '#{action_name}'" do
        expect(described_class).to receive(:run).with(args).and_call_original
        expect(described_class).to receive(:perform_action).with(args).and_call_original
        expect(described_class).to receive(:action_from_args).with(args).and_call_original

        expect(described_class::Orchestrator).to receive(:perform).with(expected_action)

        described_class.run(args)
      end
    end

    context 'with no args' do
      let(:args) { [] }

      include_examples :runs_from_args, 'print_info_banner'
    end

    context 'with args' do
      let(:args) { 'local unset'.split }

      include_examples :runs_from_args, 'unset_local_version'
    end
  end
end
