class SubmissionsController < ApplicationController

  load_and_authorize_resource

  def new
    @agreement_display = ContentBlock.for(:agreement)
  end

  def create
    @submission.submitter = current_user
    if @submission.valid?
      if @submission.passed_screening?
        deposit_agreement_path = Submissions::DocumentDepositAgreement.call(@submission.submitter)
        submission_folder = Submissions::InitializeSubmissionFolder.call(@submission.submitter,
                                                                         deposit_agreement: deposit_agreement_path)
        SubmissionsMailer.notify_success(@submission, submission_folder).deliver_now
        render :create
      else
        SubmissionsMailer.notify_screened_out(@submission).deliver_now
        render :screened_out
      end
    else
      SubmissionsMailer.notify_error(@submission).deliver_now
      render :error
    end
  end

  def create_params
    params.require(:submission).permit(*Submission::ATTRIBUTES)
  end

end
