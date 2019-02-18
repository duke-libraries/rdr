require 'rails_helper'

module Rdr
  RSpec.describe FixityCheckFailureService do

    describe '.call' do
      let(:file_set) { FileSet.new(id: 'test') }
      let(:checksum_audit_log) { ChecksumAuditLog.new(file_set_id: file_set.id,
                                                      file_id: 'file_id',
                                                      checked_uri: 'checked uri',
                                                      expected_result: 'expected_result') }
      it 'initiates a checksum failure email' do
        expect(ChecksumVerificationMailer).to receive_message_chain(:notify_failure, :deliver_now)
        described_class.call(file_set, checksum_audit_log: checksum_audit_log)
      end
    end

  end
end

