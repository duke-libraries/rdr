class ExportFilesJob < ApplicationJob

  queue_as = :export

  def perform(repo_id, user_id, basename)
    user = User.find(user_id) if user_id
    export = ExportFiles::Package.call(repo_id, ability: user.ability, basename: basename)
    ExportFilesMailer.notify_success(export, user).deliver_now if user
  end

end
