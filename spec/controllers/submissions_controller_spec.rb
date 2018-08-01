require 'rails_helper'

RSpec.describe SubmissionsController, type: :controller do

  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe 'new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'create' do
    it 'creates a submission object' do
      post :create, params: { submission: { screening_guidelines: 'yes' } }
      expect(assigns[:submission].submitter).to eq(user)
    end
    it 'validates the submission object' do
      expect_any_instance_of(Submission).to receive(:valid?)
      post :create, params: { submission: { deposit_agreement: Submission::AGREE } }
    end
    describe 'submission valid' do
      before do
        allow_any_instance_of(Submission).to receive(:valid?) { true }
      end
      describe 'submission passed screening' do
        let(:deposit_agreement_path) { '/tmp/deposit_agreement.txt' }
        let(:deposit_instructions_path) { '/tmp/deposit_instructions.txt' }
        let(:folder_name) { "abcdef_201806141734" }
        let(:manifest_path) { '/tmp/manifest.csv' }
        let(:submission_folder) { double('BoxrMash', etag: '0',  id: '48011140270', name: folder_name, type: 'folder') }
        before do
          allow(Submissions::DocumentDepositAgreement).to receive(:call) { deposit_agreement_path }
          allow(Submissions::CreateDepositInstructions).to receive(:call) { deposit_instructions_path }
          allow(Submissions::CreateManifest).to receive(:call) { manifest_path }
          allow(Submissions::InitializeSubmissionFolder).to receive(:call) { submission_folder }
        end
        describe 'deposit agreement' do
          it 'documents the deposit agreement' do
            expect(Submissions::DocumentDepositAgreement).to receive(:call).with(user)
            post :create, params: { submission: { deposit_agreement: Submission::AGREE } }
          end
        end
        describe 'deposit instructions' do
          it 'creates the deposit instructions text file' do
            expect(Submissions::CreateDepositInstructions).to receive(:call)
            post :create, params: { submission: { deposit_agreement: Submission::AGREE } }
          end
        end
        describe 'manifest file' do
          it 'generates a manifest file' do
            expect(Submissions::CreateManifest).to receive(:call)
            post :create, params: { submission: { deposit_agreement: Submission::AGREE } }
          end
        end
        describe 'submission folder initialization' do
          it 'initializes a submission folder' do
            expect(Submissions::InitializeSubmissionFolder).to receive(:call)
                                                                   .with(user,
                                                                         deposit_agreement: deposit_agreement_path,
                                                                         deposit_instructions: deposit_instructions_path,
                                                                         manifest: manifest_path)
            post :create, params: { submission: { deposit_agreement: Submission::AGREE } }
          end
        end
        describe 'notifications' do
          it 'emails a success message' do
            expect(SubmissionsMailer).to receive(:notify_success).and_call_original
            expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now)
            post :create, params: { submission: { deposit_agreement: Submission::AGREE } }
          end
          it 'renders the create page' do
            post :create, params: { submission: { deposit_agreement: Submission::AGREE } }
            expect(response).to render_template(:create)
          end
        end
      end
      describe 'submission did not pass screening' do
        it 'emails a screened out message' do
          expect(SubmissionsMailer).to receive(:notify_screened_out).and_call_original
          expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now)
          post :create, params: { submission: { screening_guidelines: 'no' } }
        end
        it 'renders the screened out page' do
          post :create, params: { submission: { screening_guidelines: 'no' } }
          expect(response).to render_template(:screened_out)
        end
      end
    end
    describe 'submission not valid' do
      before do
        allow_any_instance_of(Submission).to receive(:valid?) { false }
      end
      it 'emails an error message' do
        expect(SubmissionsMailer).to receive(:notify_error).and_call_original
        expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now)
        post :create, params: { submission: { deposit_agreement: Submission::AGREE } }
      end
      it 'renders the error page' do
        post :create, params: { submission: { deposit_agreement: Submission::AGREE } }
        expect(response).to render_template(:error)
      end
    end
  end

end
