module API::V1
  class BaseController < ::ActionController::API
    include ActionController::MimeResponds
    include ActionView::Rendering

    rescue_from ActiveRecord::RecordNotFound do |exc|
      head :not_found
    end

  end
end
