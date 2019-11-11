require "ezid-client"
require "securerandom"

module Ezid
  class MockIdentifier < Identifier

    self.defaults = {}

    def load_metadata; self; end
    def reset_metadata; self; end

    private

    def mint
      self.id = SecureRandom.hex(4)
    end

    def create; end
    def modify; end

  end
end
