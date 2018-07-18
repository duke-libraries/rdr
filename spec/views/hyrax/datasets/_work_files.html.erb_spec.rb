require 'rails_helper'

RSpec.describe 'hyrax/datasets/_work_files.html.erb', type: :view do
  let(:solr_document) { SolrDocument.new }
  let(:presenter) { Hyrax::DatasetPresenter.new(solr_document, ability) }
  let(:ability) { Ability.new(user) }
  let(:user) { FactoryBot.build(:user) }
  let(:expected_file_count_size) { /.*<dd>7 files \(11.8 MB\)<\/dd>.*/ }

  before do
    allow(presenter).to receive(:file_scan) { WorkFilesScanner::ScanResults.new(7, 12345678) }
  end

  it "renders the file count and size" do
    render 'hyrax/datasets/work_files.html.erb', presenter: presenter
    expect(rendered).to match(expected_file_count_size)
  end

end
