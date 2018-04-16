require 'rails_helper'

RSpec.describe 'hyrax/datasets/_altmetric_badge.html.erb', type: :view do
  let(:presenter) { Hyrax::DatasetPresenter.new(solr_document, ability) }
  let(:solr_document) { SolrDocument.new }
  let(:ability) { Ability.new(user) }
  let(:user) { FactoryBot.build(:user) }

  context "when the work has a DOI" do
    before do
      allow(presenter).to receive(:doi).and_return('10.1073/abcd.123456789')
      render 'hyrax/datasets/altmetric_badge.html.erb', presenter: presenter
    end
    it "renders badge markup" do
      expect(rendered).to include('altmetric-embed')
    end
  end

  context "when the work does not have a DOI" do
    before do
      allow(presenter).to receive(:doi).and_return([])
      render 'hyrax/datasets/altmetric_badge.html.erb', presenter: presenter
    end
    it "does not render badge markup" do
      expect(rendered).not_to include('altmetric-embed')
    end
  end

end