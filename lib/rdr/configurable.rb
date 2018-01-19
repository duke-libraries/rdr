module Rdr
  module Configurable
    extend ActiveSupport::Concern

    included do
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
