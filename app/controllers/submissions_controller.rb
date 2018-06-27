class SubmissionsController < ApplicationController

  load_and_authorize_resource

  def new
    @agreement_display = ContentBlock.for(:agreement)
  end

  def create
    @submission.submitter = current_user
    if @submission.past_screening?
      if @submission.valid?
        SubmissionsMailer.notify_success(@submission)
        render :create
      else
        SubmissionsMailer.notify_error(@submission)
        render :error
      end
    else
      SubmissionsMailer.notify_screened_out(@submission)
      render :screened_out
    end
  end

  def create_params
    params.require(:submission).permit(*Submission::ATTRIBUTES)
  end

end
