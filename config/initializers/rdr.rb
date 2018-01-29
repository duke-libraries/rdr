require 'rdr'

Rdr.configure do |config|
  config.preferred_admin_set_id = ENV['PREFERRED_ADMIN_SET_ID'] || AdminSet::DEFAULT_ID
end
