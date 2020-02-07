module Api::V1
  class StatusController < BaseController

    def index
      render json: ::Status.new
    end

  end
end
