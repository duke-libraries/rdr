class ChecksumVerificationJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(wrapper)
    service = ChecksumVerificationService.new(wrapper)
    service.verify_checksum
  rescue Rdr::ChecksumInvalid => e
    notify_user(wrapper, e)
    raise e
  end

  def notify_user(wrapper, error)
    user = user_to_notify(wrapper)
    ChecksumVerificationMailer.notify_failure(error, user).deliver_now! if user
  end

  def user_to_notify(wrapper)
    fs = FileSet.find(wrapper.file_set_id)
    wrk = fs.parent
    case
      when wrk.proxy_depositor.present?
        User.find_by_user_key(wrk.proxy_depositor)
      when wrk.depositor.present?
        User.find_by_user_key(wrk.depositor)
      else # edge case, unlikely to occur in reality
        wrapper.user
    end
  end

end
