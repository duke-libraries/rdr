class ExportFilesJob < ApplicationJob

  queue_as = :export

  # ExportFilesJob is usually called with either the ID of an existing user or an email address.
  # In the case where it is called with both, we package the export files based on the ability of the existing user
  # but send the email notification to the provided email address (which may or may not be the email of the logged in
  # user).  This scenario is something of an edge case, where an export is initiated as an unlogged in user (and an
  # email address provided) but completed as a logged in user.
  def perform(repo_id, user_id, email_address, basename)
    user = user_id ? User.find(user_id) : User.new
    email_addr = email_address_to_use(user_id, email_address)
    export = ExportFiles::Package.call(repo_id, ability: user.ability, basename: basename)
    ExportFilesMailer.notify_success(export, email_addr).deliver_now
  end

  def email_address_to_use(user_id, email_address)
    email_address.present? ? email_address : User.find(user_id).email
  end

end
