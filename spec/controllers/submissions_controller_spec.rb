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
      post :create, params: { submission: { deposit_agreement: 'I agree' } }
    end
    describe 'submission valid' do
      before do
        allow_any_instance_of(Submission).to receive(:valid?) { true }
      end
      describe 'submission passed screening' do
        let(:deposit_agreement_path) { '/tmp/deposit_agreement.txt' }
        before do
          allow(Submissions::DocumentDepositAgreement).to receive(:call) { deposit_agreement_path }
          allow(Submissions::InitializeSubmissionFolder).to receive(:call)
        end
        describe 'deposit agreement' do
          it 'documents the deposit agreement' do
            expect(Submissions::DocumentDepositAgreement).to receive(:call).with(user)
            post :create, params: { submission: { deposit_agreement: 'I agree' } }
          end
        end
        describe 'manifest file' do
          it 'generates a manifest file'
        end
        describe 'submission folder initialization' do
          it 'initializes a submission folder' do
            expect(Submissions::InitializeSubmissionFolder).to receive(:call)
                                                                   .with(user,
                                                                         deposit_agreement: deposit_agreement_path)
            post :create, params: { submission: { deposit_agreement: 'I agree' } }
          end
        end
        describe 'notifications' do
          before do
            allow(Submissions::DocumentDepositAgreement).to receive(:call)
            allow(Submissions::InitializeSubmissionFolder).to receive(:call)
          end
          it 'emails a success message' do
            expect(SubmissionsMailer).to receive(:notify_success)
            post :create, params: { submission: { deposit_agreement: 'I agree' } }
          end
          it 'renders the create page' do
            post :create, params: { submission: { deposit_agreement: 'I agree' } }
            expect(response).to render_template(:create)
          end
        end
      end
      describe 'submission did not pass screening' do
        it 'emails a screened out message' do
          expect(SubmissionsMailer).to receive(:notify_screened_out)
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
        expect(SubmissionsMailer).to receive(:notify_error)
        post :create, params: { submission: { deposit_agreement: 'I agree' } }
      end
      it 'renders the error page' do
        post :create, params: { submission: { deposit_agreement: 'I agree' } }
        expect(response).to render_template(:error)
      end
    end
  end

end
