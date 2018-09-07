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
        describe 'invalid header' do
          let(:manifest_file) do
            File.join(fixture_path, 'importer', 'manifest_samples', 'invalid_headers.csv')
          end
          it 'has an invalid header error' do
            expect(subject).to_not be_valid
            expect(subject.errors.messages[:base])
                .to include(I18n.t('rdr.batch_import.invalid_metadata_header', header: 'bad_header'))
            expect(subject.errors.messages[:base])
                .to include(I18n.t('rdr.batch_import.invalid_metadata_header', header: 'ungood_header'))
          end
        end
        describe 'invalid controlled vocabulary metadata value' do
          let(:manifest_file) do
            File.join(fixture_path, 'importer', 'manifest_samples', 'invalid_controlled_vocab_values.csv')
          end
          it 'has an invalid metadata value error' do
            expect(subject).to_not be_valid
            expect(subject.errors.messages[:license])
                .to include(I18n.t('rdr.batch_import.invalid_metadata_value', value: 'bad_license'))
            expect(subject.errors.messages[:resource_type])
                .to include(I18n.t('rdr.batch_import.invalid_metadata_value', value: 'bad_resource_type'))
            expect(subject.errors.messages[:rights_statement])
                .to include(I18n.t('rdr.batch_import.invalid_metadata_value', value: 'bad_rights_statement'))
          end
        end
        describe 'file does not exist' do
          it 'has a file existence error' do
            expect(subject).to_not be_valid
            expect(subject.errors.messages[:files])
                .to include(I18n.t('rdr.batch_import.nonexistent_file',
                                   path: File.join(files_directory, 'data/data1.csv')))
          end
        end
        describe 'on behalf of user does not exist' do
          let(:manifest_file) do
            File.join(fixture_path, 'importer', 'manifest_samples', 'nonexistent_user.csv')
          end
          it 'has a nonexistent user error' do
            expect(subject).to_not be_valid
            expect(subject.errors.messages[:on_behalf_of]).to include(I18n.t('rdr.batch_import.nonexistent_user', user_key: 'abc@inst.edu'))
          end
        end
      end
    end
  end
end
