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
