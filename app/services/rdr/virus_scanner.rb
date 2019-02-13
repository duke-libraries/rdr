require 'ddr-antivirus'

module Rdr
  class VirusScanner < Hydra::Works::VirusScanner

    def infected?
      begin
        Ddr::Antivirus.scan(file)
      rescue Ddr::Antivirus::ScannerError => e
        Rails.logger&.error(e)
        raise e
      rescue Ddr::Antivirus::VirusFoundError => e
        Rails.logger&.warn(I18n.t('rdr.virus_found', file: file, error_msg: e.message))
        true
      else
        false
      end
    end

  end
end
