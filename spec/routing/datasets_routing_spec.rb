require 'rails_helper'

RSpec.describe 'datasets routing', type: :routing do

  let(:id) { '3484zg88m' }

  it 'has an assign_register_doi route' do
    route = { controller: 'hyrax/datasets', action: 'assign_register_doi', id: id }
    expect(post: "/concern/datasets/#{id}/assign_register_doi").to route_to(route)
    expect(post: assign_register_doi_hyrax_dataset_path(id)).to route_to(route)
  end

end
