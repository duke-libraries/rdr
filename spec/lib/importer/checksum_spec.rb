require 'rails_helper'

module Importer
  RSpec.describe Checksum, type: :model do

    let(:checksum_filepath) { File.join(fixture_path, 'importer', 'checksums.txt') }

    describe '.import_data' do
      it 'adds table entries for new paths' do
        expect { described_class.import_data(checksum_filepath) }.to change{ described_class.count }.from(0).to(3)
      end
      it 'does not add table entries for existing paths' do
        described_class.import_data(checksum_filepath)
        expect { described_class.import_data(checksum_filepath) }.to_not change{ described_class.count }
      end
      it 'handles entries with spaces in the path' do
        described_class.import_data(checksum_filepath)
        expect(Importer::Checksum.all.map(&:path)).to include('/base/path/subpath/file01002 revised.dat')
      end
    end

    describe '#checksum' do
      before { described_class.import_data(checksum_filepath) }
      describe 'provided' do
        it 'returns the provided checksum' do
          expect(described_class.checksum('/base/path/subpath/file01002 revised.dat')).
              to eq('ea14084df3e55b170e7063d6ac705b33423921fc69e4edcbc843743b6651b1cb')
        end
      end
      describe 'provided' do
        it 'returns nil' do
          expect(described_class.checksum('/base/path/subpath/donothave.dat')).to be nil
        end
      end
    end
  end
end
