require 'rdr'

Rdr.configure do |config|
  config.preferred_admin_set_id = ENV['preferred_admin_set_id'] || AdminSet::DEFAULT_ID
end
