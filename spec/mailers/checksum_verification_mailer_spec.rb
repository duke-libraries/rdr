require 'rails_helper'

RSpec.describe ChecksumVerificationMailer do

  let(:user) { FactoryBot.create(:user) }
  let(:error_msg) { 'invalid checksum error message' }
  let(:error) { Rdr::ChecksumInvalid.new(error_msg) }

  describe "notify_failure" do
    it "works" do
      described_class.notify_failure(error).deliver_now!
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq(I18n.t('rdr.checksum_verification_failure_heading'))
      expect(mail.body).to match(error_msg)
    end
  end

end
