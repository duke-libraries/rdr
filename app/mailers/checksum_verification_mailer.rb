class ChecksumVerificationMailer < ApplicationMailer

  def notify_failure(error, user)
    @error = error
    subject = t('rdr.checksum_verification_failure_heading')
    mail(to: user.email, subject: subject)
  end

end
