require 'rails_helper'

RSpec.describe ExportFilesController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:work) { FactoryBot.create(:work) }

  before do
    sign_in user
  end

  describe "success" do
    specify {
      post :create, params: { id: work.id, basename: "foo", confirmed: true }
      expect(response).to be_success
    }
  end

end
