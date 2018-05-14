class LocalUrlsController < ApplicationController

  def show
    redirect_to resolve_id
  end

  def resolve_id
    local_url_id = params.require(:local_url_id)
    ActiveFedora::Base.find_by_ark(local_url_id)
  end

end
