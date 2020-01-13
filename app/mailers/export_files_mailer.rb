class ExportFilesMailer < ApplicationMailer

  def notify_success(export, email_address)
    @export = export
    subject = "RDR File Export COMPLETED (#{@export.repo_id})"
    mail(to: email_address, subject: subject)
  end

end
