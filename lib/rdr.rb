require 'rdr/version'
require 'rdr/error'

module Rdr
  extend ActiveSupport::Autoload

  autoload :Configurable
  autoload :Index
  autoload :Notifications

  include Rdr::Configurable

end
