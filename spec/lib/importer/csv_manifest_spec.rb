require 'rails_helper'

module Importer
  RSpec.describe CSVManifest do

    describe 'validation' do
      let(:manifest_file) { File.join(fixture_path, 'importer', 'manifest_samples', 'basic.csv') }
      let(:files_directory) { '/tmp' }
      subject { described_class.new(manifest_file, files_directory) }
      describe 'valid manifest' do
        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with(File.join(files_directory, 'data/data1.csv')) { true }
          allow(File).to receive(:exist?).with(File.join(files_directory, 'data/data2.csv')) { true }
          allow(File).to receive(:exist?).with(File.join(files_directory, 'data/data3.csv')) { true }
          allow(File).to receive(:exist?).with(File.join(files_directory, 'docs/doc1.txt')) { true }
          allow(File).to receive(:exist?).with(File.join(files_directory, 'docs/doc2.txt')) { true }
        end
        it 'is valid' do
          expect(subject).to be_valid
        end
      end
      describe 'invalid manifest' do
        describe 'file does not exist' do
          it 'has a file existence error' do
            expect(subject).to_not be_valid
            expect(subject.errors.messages[:files]).
                                      to include("File not found: #{File.join(files_directory, 'data/data1.csv')}")
          end
        end
      end
    end
  end
end
