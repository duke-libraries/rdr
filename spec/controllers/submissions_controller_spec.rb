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
    describe 'submission valid'
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
