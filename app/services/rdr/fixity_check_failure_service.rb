module Rdr
  class FixityCheckFailureService

    def self.call(file_set, checksum_audit_log:)
      error_msg = <<~EOS
        Research Data Repository fixity check failure
        FileSet #{file_set.id} failed fixity check.

        Details:
          file_set_id: #{checksum_audit_log.file_set_id}
          file_id: #{checksum_audit_log.file_id}
          checked_uri: #{checksum_audit_log.checked_uri}
          expected_result: #{checksum_audit_log.expected_result}
      EOS
      error = Rdr::ChecksumInvalid.new(error_msg)
      ChecksumVerificationMailer.notify_failure(error).deliver_now
    end

  end
end
