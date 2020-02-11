require 'rdr'

# use EZID test mode for non-production environments
unless Rails.env.production?
  require 'ezid/test_helper'
  ezid_test_mode!
end

Hydra::Works.default_system_virus_scanner = Rdr::VirusScanner

if Rails.env.test?
  Ddr::Antivirus.test_mode!
else
  Ddr::Antivirus.scanner_adapter = :clamd
end

# Load overrides & extensions for Hyrax core's schema.org mappings
# https://github.com/samvera/hyrax/blob/master/app/services/hyrax/microdata.rb#L32-L34
# https://github.com/samvera/hyrax/blob/master/config/schema_org.yml
Hyrax::Microdata.load_paths << 'config/schema_org.yml'
