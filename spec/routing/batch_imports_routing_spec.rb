require 'rails_helper'

RSpec.describe 'batch imports routing', type: :routing do

  it 'has a new route' do
    route = { controller: 'batch_imports', action: 'new' }
    expect(:get => '/batch_imports/new').to route_to(route)
    expect(:get => new_batch_import_path).to route_to(route)
  end

  it 'has a create route' do
    route = { controller: 'batch_imports', action: 'create' }
    expect(:post => '/batch_imports').to route_to(route)
    expect(:post => batch_imports_path).to route_to(route)
  end

end
