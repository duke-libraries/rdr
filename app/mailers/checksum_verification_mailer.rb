class ChecksumVerificationMailer < ApplicationMailer

  def notify_failure(error)
    @error = error
    subject = t('rdr.checksum_verification_failure_heading')
    mail(to: Rdr.curation_group_email, subject: subject)
  end

end
