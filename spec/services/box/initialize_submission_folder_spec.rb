require 'rails_helper'

module Box
  RSpec.describe InitializeSubmissionFolder do

    let(:user) { User.new(uid: 'abcdef@duke.edu') }
    let(:deposit_agreement_path) { '/tmp/dep-agr/deposit_agreement.txt' }
    let(:manifest_path) { '/tmp/manifest.csv' }
    let(:folder_name) { "abcdef_201806141734" }
    let(:submission_folder) { double('BoxrMash', etag: '0',  id: '48011140270', name: folder_name, type: 'folder') }

    subject { described_class.new(user, deposit_agreement: deposit_agreement_path, manifest: manifest_path) }

    before do
      allow(Box::AccessToken).to receive_message_chain(:last, :token) { 'access_token' }
      allow(Box::RefreshToken).to receive_message_chain(:last, :token) { 'refresh_token' }
    end

    describe '#call' do
      before do
        allow(Time).to receive(:now) { Time.new(2018, 6, 14, 17, 34, 23) }
      end

      describe 'submission folder creation' do
        before do
          allow_any_instance_of(Box::Client).to receive(:add_deposit_agreement)
          allow_any_instance_of(Box::Client).to receive(:add_manifest_file)
          allow_any_instance_of(Box::Client).to receive(:add_collaborator)
        end
        it 'creates a submission folder' do
          expect_any_instance_of(Box::Client).to receive(:create_rdr_submission_folder).with(folder_name)
          subject.call
        end
      end

      describe 'deposit agreement addition' do
        before do
          allow_any_instance_of(Box::Client).to receive(:create_rdr_submission_folder) { submission_folder }
          allow_any_instance_of(Box::Client).to receive(:add_manifest_file)
          allow_any_instance_of(Box::Client).to receive(:add_collaborator)
        end
        it 'adds the deposit agreement to the submission folder' do
          expect_any_instance_of(Box::Client).to receive(:add_deposit_agreement).with(submission_folder, deposit_agreement_path)
          subject.call
        end
      end

      describe 'manifest addition' do
        before do
          allow_any_instance_of(Box::Client).to receive(:create_rdr_submission_folder) { submission_folder }
          allow_any_instance_of(Box::Client).to receive(:add_deposit_agreement)
          allow_any_instance_of(Box::Client).to receive(:add_collaborator)
        end
        it 'adds the manifest file to the submission folder' do
          expect_any_instance_of(Box::Client).to receive(:add_manifest_file).with(submission_folder, manifest_path)
          subject.call
        end
      end

      describe 'collaborator setting' do
        before do
          allow_any_instance_of(Box::Client).to receive(:create_rdr_submission_folder) { submission_folder }
          allow_any_instance_of(Box::Client).to receive(:add_deposit_agreement)
          allow_any_instance_of(Box::Client).to receive(:add_manifest_file)
        end
        it 'sets the user as a collaborator on the submission folder' do
          expect_any_instance_of(Box::Client).to receive(:add_collaborator).with(submission_folder, user.user_key)
          subject.call
        end
      end

    end
  end
end
