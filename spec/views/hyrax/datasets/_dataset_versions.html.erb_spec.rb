require 'rails_helper'

RSpec.describe 'hyrax/datasets/_dataset_versions.html.erb', type: :view do
  let(:presenter) { Hyrax::DatasetPresenter.new(solr_document, ability) }
  let(:solr_document) { SolrDocument.new(Rdr::Index::Fields.available => [ '2007-02-03T00:00:00Z' ]) }
  let(:ability) { Ability.new(user) }
  let(:user) { FactoryBot.build(:user) }

  before do
    allow(presenter).to receive(:dataset_versions).and_return([ solr_document ])
    render 'hyrax/datasets/dataset_versions.html.erb', presenter: presenter
  end

  it "renders the publication date table contents in YYYY-MM-DD format" do
    expect(rendered).to match(/.*<td>\s*2007-02-03\s*<\/td>.*/)
  end

end
