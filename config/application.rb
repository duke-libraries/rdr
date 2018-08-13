require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Rdr
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += %W(#{config.root}/lib)

    config.active_job.queue_adapter = :inline

    # Inject/override behaviors in existing classes without having to override the entire class.
    # Docs: http://samvera.github.io/patterns-presenters.html#overriding-and-custom-presenter-methods
    config.to_prepare do
      Hyrax::PermissionBadge.prepend PrependedPresenters::PermissionBadge
    end

  end
end
