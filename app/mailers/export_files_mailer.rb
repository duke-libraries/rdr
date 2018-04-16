class ExportFilesMailer < ApplicationMailer

  def notify_success(export, user)
    @export = export
    subject = "RDR File Export COMPLETED (#{@export.repo_id})"
    mail(to: user.email, subject: subject)
  end

end
