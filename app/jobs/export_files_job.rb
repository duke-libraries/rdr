class ExportFilesJob < ApplicationJob

  queue_as = :export

  # ExportFilesJob expects to be called with either the ID of an existing user or an email address.
  # Calling it with both is an error.
  def perform(repo_id, user_id, user_email, basename)
    if user_id && user_email.present?
      raise ArgumentError, I18n.t('rdr.export_files.job_user_id_and_email_error')
    end
    user = user_id ? User.find(user_id) : User.new(email: user_email)
    export = ExportFiles::Package.call(repo_id, ability: user.ability, basename: basename)
    ExportFilesMailer.notify_success(export, user).deliver_now
  end

end
