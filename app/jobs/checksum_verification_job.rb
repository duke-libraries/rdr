class ChecksumVerificationJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(wrapper)
    service = ChecksumVerificationService.new(wrapper)
    service.verify_checksum
  rescue Rdr::ChecksumInvalid => e
    notify(wrapper, e)
    raise e
  end

  def notify(wrapper, error)
    ChecksumVerificationMailer.notify_failure(error).deliver_now
  end

end
