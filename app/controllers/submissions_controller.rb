class SubmissionsController < ApplicationController

  load_and_authorize_resource

  def create
    @submission.submitter = current_user
  end

end
