class ChecksumVerificationJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(wrapper)
    service = ChecksumVerificationService.new(wrapper)
    service.verify_checksum
  end

end
