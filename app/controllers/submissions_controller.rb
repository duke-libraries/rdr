class SubmissionsController < ApplicationController

  load_and_authorize_resource

  def create
    @submission.submitter = current_user

    if @submission.valid?
    else
      SubmissionsMailer.notify_error(@submission)
      render :error
    end
  end

end
