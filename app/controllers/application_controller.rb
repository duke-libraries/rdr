class ApplicationController < ActionController::Base

  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  protect_from_forgery with: :exception

  # https://github.com/plataformatec/devise#strong-parameters
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Added during upgrade to Hyrax v2.1.0 to avoid flash messages being discarded by Blacklight for XHR requests
  skip_after_action :discard_flash_if_xhr

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email])
  end

end
