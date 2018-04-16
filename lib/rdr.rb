require 'rdr/error'

module Rdr
  extend ActiveSupport::Autoload

  autoload :Configurable
  autoload :Error
  autoload :Index
  autoload :Notifications

  include Rdr::Configurable

end
