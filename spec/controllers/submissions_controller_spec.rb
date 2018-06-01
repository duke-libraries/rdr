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
      post :create
      expect(assigns[:submission].user_key).to eq(user.user_key)
    end
  end

end
