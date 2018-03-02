module Rdr
  extend ActiveSupport::Autoload

  autoload :Configurable
  autoload :Error
  autoload :ChecksumInvalid, 'rdr/error'
  autoload :UnexpectedMultipleResultsError, 'rdr/error'
  autoload :Index
  autoload :Notifications

  include Rdr::Configurable

end
