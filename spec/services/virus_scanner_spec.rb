require 'rails_helper'

module Rdr
  RSpec.describe VirusScanner do

    let(:file_path) { '/path/to/file' }
    let(:scan_result) { Ddr::Antivirus::ScanResult.new(file_path, 'scan_result') }

    describe '.infected?' do
      describe 'infected file' do
        before do
          allow_any_instance_of(Ddr::Antivirus::NullScannerAdapter).to receive(:scan).
              and_raise(Ddr::Antivirus::VirusFoundError.new(scan_result))
        end
        it 'returns true' do
          expect(Rails.logger).to receive(:warn)
          result = described_class.infected?(file_path)
          expect(result).to be true
        end
      end
      describe 'non-infected file' do
        it 'returns false' do
          expect(described_class.infected?(file_path)).to be false
        end
      end
    end
  end
end
