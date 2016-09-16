require 'spec_helper'
require 'pgbinder/orchestrator/questioner'

describe PGBinder::Orchestrator::Questioner do
  context '#all_clear?' do
    let(:subject) { described_class.all_clear?(question) { print to_yield } }

    shared_examples :emulates_reply_to_question_and_yields_smth do |reply|
      let(:question) { 'About to do this.' }
      let(:to_yield) { 'Roger.' }

      let(:expected_yield) { reply == 'Y' ? to_yield : '' }
      let(:expected_status) { reply == 'Y' ? 'Done' : 'Aborted' }

      it "does #{reply == 'Y' ? '' : 'not '}yield" do
        io = double

        expect(ARGV).to receive(:clear)
        expect(described_class).to receive(:gets).and_return(io).once

        expect(io).to receive(:chomp).and_return(reply)

        expect { subject }.to output(
          <<-EOS
#{question} Do you want to proceed? [Yn] #{expected_yield}#{expected_status}.
EOS
        ).to_stdout
      end
    end

    context 'when replying positively' do
      include_examples :emulates_reply_to_question_and_yields_smth, 'Y'
    end

    context 'when replying negatively' do
      include_examples :emulates_reply_to_question_and_yields_smth, 'N'
    end
  end
end
