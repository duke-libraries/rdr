require 'rdr'

Rdr.configure do |config|
  config.preferred_admin_set_id = ENV['PREFERRED_ADMIN_SET_ID'] || AdminSet::DEFAULT_ID
end

# use EZID test mode for non-production environments
unless Rails.env.production?
  require 'ezid/test_helper'
  ezid_test_mode!
end
