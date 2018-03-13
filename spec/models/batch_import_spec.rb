require 'rails_helper'

RSpec.shared_examples 'an invalid batch import' do
  it 'reports the error' do
    subject.validate
    expect(subject.errors.full_messages).to include(error_msg)
  end
end

RSpec.describe BatchImport do

  describe 'validation' do
    let(:basepath) { '/' }
    let(:on_behalf_of_user) { FactoryBot.build(:user) }
    let(:manifest_file) { File.join(fixture_path, 'importer', 'dataset', 'manifest.csv') }
    let(:files_directory) { File.join(fixture_path, 'importer', 'dataset', 'files') }
    let(:checksum_file) { File.join(fixture_path, 'importer', 'dataset', 'checksums.txt') }
    let(:on_behalf_of) { on_behalf_of_user.user_key }
    let(:args) { { 'manifest_file' => manifest_file, 'files_directory' => files_directory,
                   'checksum_file' => checksum_file, 'on_behalf_of' => on_behalf_of } }

    before do
      allow(User).to receive(:find_by_user_key).with(on_behalf_of_user.user_key) { on_behalf_of_user }
    end

    subject { described_class.new(args) }

    before do
      allow(File).to receive(:read).with(BatchImport::DEFAULT_CONFIG_FILE) { "basepath: #{basepath}\n" }
    end

    describe 'valid batch import' do
      it { is_expected.to be_valid }
    end
    describe 'invalid batch import' do
      describe 'manifest file does not exist' do
        let(:file_path) { File.join(basepath, manifest_file) }
        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with(file_path) { false }
        end
        let(:error_msg) { "Manifest file #{I18n.t('rdr.does_not_exist', target: file_path)}" }
        it_behaves_like 'an invalid batch import'
      end
      describe 'files directory does not exist' do
        before do
          allow(Dir).to receive(:exist?).and_call_original
          allow(Dir).to receive(:exist?).with(files_directory) { false }
        end
        let(:error_msg) { "Files directory #{I18n.t('rdr.does_not_exist', target: files_directory)}" }
        it_behaves_like 'an invalid batch import'
      end
      describe 'checksum file does not exist' do
        let(:file_path) { File.join(basepath, checksum_file) }
        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with(file_path) { false }
        end
        let(:error_msg) { "Checksum file #{I18n.t('rdr.does_not_exist', target: file_path)}" }
        it_behaves_like 'an invalid batch import'
      end
      describe 'on behalf of user does not exist' do
        before do
          allow(User).to receive(:find_by_user_key).with(on_behalf_of_user.user_key)
        end
        let(:error_msg) { "On behalf of #{I18n.t('rdr.does_not_exist', target: on_behalf_of)}" }
        it_behaves_like 'an invalid batch import'
      end
      describe 'invalid manifest' do
        describe 'manifest file has errors' do
          before do
            allow(subject).to receive(:manifest_file_exists?) { false }
          end
          it 'does not validate the contents of the manifest' do
            expect(subject).to_not receive(:manifest_contents_must_be_valid)
            subject.validate
          end
        end
        describe 'manifest has errors' do
          let(:manifest_errors) { double(full_messages: [ 'error' ]) }
          before do
            allow_any_instance_of(Importer::CSVManifest).to receive(:valid?) { false }
            allow_any_instance_of(Importer::CSVManifest).to receive(:errors) { manifest_errors }
          end
          it 'includes the manifest errors' do
            subject.validate
            expect(subject.errors.messages[:manifest_file]).to_not be_empty
          end
        end
      end
    end
  end

end
