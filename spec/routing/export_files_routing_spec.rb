require 'rails_helper'

RSpec.describe 'export files routing', type: :routing do

  let(:id) { '3484zg88m' }

  it 'has a new route' do
    route = { controller: 'export_files', action: 'new', id: id }
    expect(:get => "/export_files/#{id}").to route_to(route)
    expect(:get => export_files_path(id)).to route_to(route)
  end

  it 'has a create route' do
    route = { controller: 'export_files', action: 'create', id: id }
    expect(:post => "export_files/#{id}").to route_to(route)
    expect(:post => export_files_path(id)).to route_to(route)
  end

  it 'has an unverified email route' do
    route = { controller: 'export_files', action: 'unverified_email', id: id }
    expect(post: "export_files/#{id}/unverified_email").to route_to(route)
  end
end
