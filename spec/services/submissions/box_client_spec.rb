require 'rails_helper'
require 'box/access_token'
require 'box/refresh_token'
require 'boxr'

module Submissions
  RSpec.describe BoxClient do

    let(:box_base_folder_rdr_submissions) { '/test/box/base_folder' }
    let(:tokens) { [ 'token1', 'token2', 'token3', 'token4' ] }
    let(:token_refresh_response) { double('BoxrMash', access_token: tokens[2], refresh_token: tokens[3]) }

    before do
      Box::AccessToken.create(token: tokens[0])
      Box::RefreshToken.create(token: tokens[1])
      allow(Boxr).to receive(:refresh_tokens) { token_refresh_response }
      allow(Rdr).to receive(:box_base_folder_rdr_submissions) { box_base_folder_rdr_submissions }
    end

    describe '.refresh_tokens' do
      describe 'success' do
        it 'stores new access and refresh tokens' do
          expect { described_class.refresh_tokens }.to change{ Box::AccessToken.last }
                                                           .and(change { Box::RefreshToken.last })
        end
      end
      describe 'Boxr error' do
        let(:action) { 'refreshing Box auth tokens' }
        before do
          allow(Boxr).to receive(:refresh_tokens).and_raise(Boxr::BoxrError)
        end
        it 'does not update access and refresh tokens' do
          begin
            expect { described_class.refresh_tokens }.to_not change{ Box::AccessToken.last }
            expect { described_class.refresh_tokens }.to_not change{ Box::RefreshToken.last }
          rescue Rdr::BoxError
          end
        end
        it 'logs the error' do
          begin
            expect(Rails.logger).to receive(:error).with(/Error #{action}:/)
            described_class.refresh_tokens
          rescue Rdr::BoxError
          end
        end
        it 'raises a Rdr::BoxError' do
          expect { described_class.refresh_tokens }.to raise_error(Rdr::BoxError, /Error #{action}:/)
        end

      end
    end

    describe '#rdr_submissions_base_folder' do
      it 'calls the Boxr client to retrieve the RDR submissions base folder' do
        expect(subject.boxr_client).to receive(:folder_from_path).with(Rdr.box_base_folder_rdr_submissions)
        subject.rdr_submissions_base_folder
      end
      describe 'Boxr error' do
        let(:action) { "retrieving RDR submissions base folder #{Rdr.box_base_folder_rdr_submissions}" }
        before do
          allow(subject.boxr_client).to receive(:folder_from_path).with(Rdr.box_base_folder_rdr_submissions).
              and_raise(Boxr::BoxrError)
        end
        it 'logs the error' do
          begin
            expect(Rails.logger).to receive(:error).with(/Error #{action}:/)
            subject.rdr_submissions_base_folder
          rescue Rdr::BoxError
          end
        end
        it 'raises a Rdr::BoxError' do
          expect { subject.rdr_submissions_base_folder }.to raise_error(Rdr::BoxError, /Error #{action}:/)
        end
      end
    end

    describe '#create_rdr_submission_folder' do
      let(:folder_name) { 'abcdef_201806130803' }
      let(:rdr_submissions_base_folder) {
        double('BoxrMash', etag: '0',  id: '48101410720', name: 'RDR Submissions', type: 'folder')
      }
      before do
        allow(subject).to receive(:rdr_submissions_base_folder) { rdr_submissions_base_folder }
      end
      it 'calls the Boxr client create folder method' do
        expect(subject.boxr_client).to receive(:create_folder).with(folder_name, rdr_submissions_base_folder)
        subject.create_rdr_submission_folder(folder_name)
      end
      describe 'Boxr error' do
        let(:action) { "creating RDR submission folder #{folder_name}" }
        before do
          allow(subject.boxr_client).to receive(:create_folder).with(folder_name, rdr_submissions_base_folder).
              and_raise(Boxr::BoxrError)
        end
        it 'logs the error' do
          begin
            expect(Rails.logger).to receive(:error).with(/Error #{action}:/)
            subject.create_rdr_submission_folder(folder_name)
          rescue Rdr::BoxError
          end
        end
        it 'raises a Rdr::BoxError' do
          expect { subject.create_rdr_submission_folder(folder_name) }.to raise_error(Rdr::BoxError, /Error #{action}:/)
        end
      end
    end

    describe '#add_deposit_agreement' do
      let(:folder) { double('BoxrMash', etag: '0',  id: '48011140270', name: 'submission', type: 'folder') }
      let(:deposit_agreement_path) { '/tmp/dep-agr/deposit_agreement.txt' }
      it 'calls the Boxr client upload file method' do
        expect(subject.boxr_client).to receive(:upload_file).with(deposit_agreement_path, folder)
        subject.add_deposit_agreement(folder, deposit_agreement_path)
      end
      describe 'Boxr error' do
        let(:action) { "adding deposit agreement #{deposit_agreement_path} to #{folder.name}" }
        before do
          allow(subject.boxr_client).to receive(:upload_file).with(deposit_agreement_path, folder).and_raise(Boxr::BoxrError)
        end
        it 'logs the error' do
          begin
            expect(Rails.logger).to receive(:error).with(/Error #{action}:/)
            subject.add_deposit_agreement(folder, deposit_agreement_path)
          rescue Rdr::BoxError
          end
        end
        it 'raises a Rdr::BoxError' do
          expect { subject.add_deposit_agreement(folder, deposit_agreement_path) }.to raise_error(Rdr::BoxError, /Error #{action}:/)
        end
      end
    end

    describe '#add_manifest_file' do
      let(:folder) { double('BoxrMash', etag: '0',  id: '48011140270', name: 'submission', type: 'folder') }
      let(:manifest_path) { '/tmp/manifest.csv' }
      it 'calls the Boxr client upload file method' do
        expect(subject.boxr_client).to receive(:upload_file).with(manifest_path, folder)
        subject.add_manifest_file(folder, manifest_path)
      end
      describe 'Boxr error' do
        let(:action) { "adding manifest file #{manifest_path} to #{folder.name}" }
        before do
          allow(subject.boxr_client).to receive(:upload_file).with(manifest_path, folder).and_raise(Boxr::BoxrError)
        end
        it 'logs the error' do
          begin
            expect(Rails.logger).to receive(:error).with(/Error #{action}:/)
            subject.add_manifest_file(folder, manifest_path)
          rescue Rdr::BoxError
          end
        end
        it 'raises a Rdr::BoxError' do
          expect { subject.add_manifest_file(folder, manifest_path) }.to raise_error(Rdr::BoxError, /Error #{action}:/)
        end
      end
    end

    describe '#add_collaborator' do
      let(:folder) { double('BoxrMash', etag: '0',  id: '48011140270', name: 'submission', type: 'folder') }
      let(:login) { "abcdef@duke.edu" }
      let(:role) { 'editor' }
      it 'calls the Boxr client add collaboration method' do
        expect(subject.boxr_client).to receive(:add_collaboration).with(folder, { login: login }, role)
        subject.add_collaborator(folder, login)
      end
      describe 'Boxr error' do
        let(:action) { "adding collaborator #{login} to #{folder.name} as #{role}" }
        describe 'already a collaborator error' do
          before do
            allow(subject.boxr_client).to receive(:add_collaboration).with(folder, { login: login }, role).
                and_raise(Boxr::BoxrError.new(status: 400, boxr_message: 'User is already a collaborator'))
          end
          it 'ignores the error' do
            expect { subject.add_collaborator(folder, login) }.to_not raise_error
          end
        end
        describe 'some error other than already a collaborator' do
          before do
            allow(subject.boxr_client).to receive(:add_collaboration).with(folder, { login: login }, role).
                and_raise(Boxr::BoxrError)
          end
          it 'logs the error' do
            begin
              expect(Rails.logger).to receive(:error).with(/Error #{action}:/)
              subject.add_collaborator(folder, login)
            rescue Rdr::BoxError
            end
          end
          it 'raises a Rdr::BoxError' do
            expect { subject.add_collaborator(folder, login) }.to raise_error(Rdr::BoxError, /Error #{action}:/)
          end
        end
      end
    end

  end
end
