module Rdr
  extend ActiveSupport::Autoload

  autoload :Configurable

  include Rdr::Configurable

end
