require 'rails_helper'

RSpec.describe "Status API routing", type: :routing do

  it "has an index route" do
    expect(get: "/api/v1/status").to route_to(controller: "api/v1/status", action: "index", format: "json")
  end

end
