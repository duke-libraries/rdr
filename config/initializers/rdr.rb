require 'rdr'

# use EZID test mode for non-production environments
unless Rails.env.production?
  require 'ezid/test_helper'
  ezid_test_mode!
end
