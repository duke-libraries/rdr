require 'ddr-antivirus'

module Rdr
  class VirusScanner < Hydra::Works::VirusScanner

    def infected?
      begin
        Ddr::Antivirus.scan(file)
      rescue Ddr::Antivirus::VirusFoundError => e
        warning(I18n.t('rdr.virus_found', file: file, error_msg: e.message))
        true
      else
        false
      end
    end

    private

    def warning(msg)
      Rails.logger&.warn(msg)
    end

  end
end
