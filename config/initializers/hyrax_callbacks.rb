# Override initialization of :after_create_concern callback to add MintPublishArkJob.perform_later
Hyrax.config.callback.set(:after_create_concern) do |curation_concern, user|
  ContentDepositEventJob.perform_later(curation_concern, user)
  MintPublishArkJob.perform_later(curation_concern)
end

# Override initialization of :after_fixity_check_failure callback to substitute our service for
# Hyrax::FixityCheckFailureService
Hyrax.config.callback.set(:after_fixity_check_failure) do |file_set, checksum_audit_log:|
  Rdr::FixityCheckFailureService.call(file_set, checksum_audit_log: checksum_audit_log)
end
