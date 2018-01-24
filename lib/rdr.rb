module Rdr
  extend ActiveSupport::Autoload

  autoload :Configurable
  autoload :Error
  autoload :UnexpectedMultipleResultsError, 'rdr/error'

  include Rdr::Configurable

end
