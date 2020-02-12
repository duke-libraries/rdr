require 'rails_helper'

module API::V1
  RSpec.describe StatusController, type: :controller do

    it "succeeds" do
      get :index
      expect(response).to be_successful
    end

  end
end
