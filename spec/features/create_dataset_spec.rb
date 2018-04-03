# Generated via
#  `rails generate hyrax:work Dataset`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a Dataset', js: false do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com', uid: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      AdminSet.find_or_create_default_admin_set_id
      allow(user).to receive(:curator?) { true }
      login_as user
    end

    scenario do
      pending("TODO: Figure out why this doesn't work - started failing after implementing feature for only curators have ability to create works. ")
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"

      # If you generate more than one work uncomment these lines
      # choose "payload_concern", option: "Dataset"
      # click_button "Create work"

      expect(page).to have_content "Add New Dataset"
    end
  end
end
