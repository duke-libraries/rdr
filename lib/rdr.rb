require 'rdr/version'
require 'rdr/error'

module Rdr
  extend ActiveSupport::Autoload

  autoload :Configurable
  autoload :Index
  autoload :Notifications

  include Rdr::Configurable

  def self.readable_date value
    Date.parse(value).to_formatted_s(:standard) rescue value
  end

end
