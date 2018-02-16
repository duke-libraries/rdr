module Rdr
  module Configurable
    extend ActiveSupport::Concern

    included do

      # URL of depositor modification request form
      mattr_accessor :depositor_request_form do
        ENV["DEPOSITOR_REQUEST_FORM"]
      end

      # ID of AdminSet to use unless otherwise specified
      mattr_accessor :preferred_admin_set_id
    end

    module ClassMethods
      def configure
        yield self
      end
    end

  end
end
