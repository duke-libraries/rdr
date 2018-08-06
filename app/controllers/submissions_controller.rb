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
        deposit_instructions_path = Submissions::CreateDepositInstructions.call
        manifest_path = Submissions::CreateManifest.call(@submission)
        submission_folder = Submissions::InitializeSubmissionFolder.call(@submission.submitter,
                                                                         deposit_agreement: deposit_agreement_path,
                                                                         deposit_instructions: deposit_instructions_path,
                                                                         manifest: manifest_path)
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
