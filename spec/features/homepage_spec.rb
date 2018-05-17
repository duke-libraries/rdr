require 'rails_helper'

RSpec.feature 'Display homepage' do

  describe 'recently uploaded datasets' do

    before do
      AdminSet.find_or_create_default_admin_set_id
      FactoryBot.create(:public_dataset, title: [ 'Analysis' ])
      FactoryBot.create(:public_dataset, title: [ 'Discussion' ], bibliographic_citation: [ 'Citation' ])
    end

    scenario do
      visit '/'
      expect(page).to have_content('Recently Uploaded Datasets')
      expect(page).to_not have_content('Depositor')
      expect(page).to have_content('Analysis')
      expect(page).to have_content('Citation')
      expect(page).to_not have_content('Discussion')
    end
  end

end
