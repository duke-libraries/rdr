require 'rails_helper'

RSpec.describe LocalUrlsController, type: :controller do

  describe '#show' do
    let(:ark) { 'ark:/99999/fk45156v36' }
    let!(:dataset) { FactoryBot.create(:dataset, ark: ark) }
    specify {
      get :show, params: { local_url_id: ark }
      expect(response).to redirect_to(dataset)
    }
  end

end
