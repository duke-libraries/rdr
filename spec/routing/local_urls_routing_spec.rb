require 'rails_helper'

RSpec.describe 'local url router', type: :routing do
  let(:ark) { 'ark:/99999/fk4' }
  it 'should have a local url id route' do
    expect(get: "/id/#{ark}").to route_to(controller: 'local_urls', action: 'show', local_url_id: ark)
  end
end
