class SubmissionsController < ApplicationController

  load_and_authorize_resource

  def create
    @submission.user_key = current_user.user_key
  end

end
