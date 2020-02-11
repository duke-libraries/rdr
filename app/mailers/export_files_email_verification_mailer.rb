class ExportFilesEmailVerificationMailer < ApplicationMailer

  def send_verification_email
    email_address = params[:email_address]
    repo_id = params[:repo_id]
    @verification_url = params[:verification_url]
    subject = I18n.t("rdr.batch_export.email_verification.subject", repo_id: repo_id)
    mail(to: email_address, subject: subject)
  end

end
