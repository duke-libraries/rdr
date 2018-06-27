require 'rails_helper'

module Submissions
  RSpec.describe DocumentDepositAgreement do

    let(:user) { FactoryBot.create(:user, uid: 'user2@duke.edu') }
    let(:deposit_agreement_html) { "<h1>Deposit</h1>\n\n<p>I agree</p>" }
    let(:deposit_agreement_text) { "Deposit\n\nI agree" }

    subject { described_class.new(user) }

    let(:file_path) { subject.call }

    before do
      ContentBlock.create(name: 'agreement_page', value: deposit_agreement_html)
    end

    after do
      FileUtils.rm_rf(File.dirname(file_path))
    end

    describe '#call' do
      it 'creates a text file' do
        expect(File.exists?(file_path)).to be true
      end
      it 'includes the deposit agreement text in the file' do
        expect(File.read(file_path)).to match(deposit_agreement_text)
      end
      it 'includes the Net ID of the submitter in the file' do
        expect(File.read(file_path)).to match(user.netid)
      end
    end

  end
end
