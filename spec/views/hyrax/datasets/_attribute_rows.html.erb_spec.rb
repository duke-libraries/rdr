require 'rails_helper'

RSpec.describe 'hyrax/datasets/_attribute_rows.html.erb', type: :view do
  let(:ability) { Ability.new(user) }
  let(:user) { FactoryBot.build(:user) }
  let(:solr_document) do
    SolrDocument.new(
      affiliation_tesim: ['Chemistry'],
      alternative_tesim: ['My secondary title'],
      ark_ssi: 'ark:/99999/fk41c36t18',
      available_dtsim: [ '2018-07-05T00:00:00Z'],
      contributor_tesim: ['Jones, Sam'],
      creator_tesim: ['Henson, Jim'],
      date_created_tesim: ['1979-04-27'],
      description_tesim: ['Bicycle rights literally deep v, lyft art party.'],
      doi_ssi: 'http://example.com/my_doi_v1',
      format_tesim: ['VHS'],
      funding_agency_tesim: ['NHPRC'],
      has_model_ssim: ['Dataset'],
      id: "08612n52b",
      language_tesim: ['English'],
      license_tesim: ['http://creativecommons.org/publicdomain/mark/1.0/'],
      publisher_tesim: ['Lulu'],
      related_url_tesim: ['Henson, Jim. (2018). The title of an article that accompanies the data. Physical Review Letters, 117(4), 045503. https://doi.org/doi:10.1103/PhysRevLett.117.045503'],
      resource_type_tesim: ['Dataset'],
      rights_note_tesim: ['Use it as you wish.'],
      rights_statement_tesim: ['http://rightsstatements.org/vocab/InC/1.0/'],
      subject_tesim: ['Libraries','Oranges'],
      temporal_tesim: ['1984-06-20'],
      title_tesim: ['Example Work With Lots of Metadata Values'],
    )
  end
  let(:presenter) { Hyrax::DatasetPresenter.new(solr_document, ability) }

  let(:page) do
    render 'hyrax/datasets/attribute_rows', presenter: presenter
    Capybara::Node::Simple.new(rendered)
  end

  describe "schema.org markup on visible fields" do
    it "alternative -> alternateName" do
      expect(page).to have_css '.attribute-alternative [itemprop="alternateName"]', text: 'My secondary title'
    end
    it "ark -> identifier" do
      expect(page).to have_css '.attribute-ark [itemprop="identifier"]', text: 'ark:/99999/fk41c36t18'
    end
    it "available -> datePublished" do
      expect(page).to have_css '.attribute-available [itemprop="datePublished"]', text: '2018-07-05'
    end
    it "contributor -> contributor" do
      expect(page).to have_css '.attribute-contributor[itemprop="contributor"] [itemprop="name"]', text: 'Jones, Sam'
    end
    it "creator -> creator" do
      expect(page).to have_css '.attribute-creator[itemprop="creator"] [itemprop="name"]', text: 'Henson, Jim'
    end
    it "doi -> identifier" do
      expect(page).to have_css '.attribute-doi [itemprop="identifier"]', text: 'http://example.com/my_doi_v1'
    end
    it "format -> encodingFormat" do
      expect(page).to have_css '.attribute-format [itemprop="encodingFormat"]', text: 'VHS'
    end
    it "funding_agency -> funder" do
      expect(page).to have_css '.attribute-funding_agency[itemprop="funder"] [itemprop="name"]', text: 'NHPRC'
    end
    it "language -> inLanguage" do
      expect(page).to have_css '.attribute-language [itemprop="inLanguage"]', text: 'English'
    end
    it "publisher -> publisher" do
      expect(page).to have_css '.attribute-publisher[itemprop="publisher"] [itemprop="name"]', text: 'Lulu'
    end
    it "related_url -> citation" do
      expect(page).to have_css '.attribute-related_url [itemprop="citation"]', text: /The title of an article that accompanies the data/
    end
    it "rights_note -> conditionsOfAccess" do
      expect(page).to have_css '.attribute-rights_note [itemprop="conditionsOfAccess"]', text: 'Use it as you wish.'
    end
    it "subject -> about" do
      expect(page).to have_css '.attribute-subject[itemprop="about"] [itemprop="name"]', text: 'Libraries'
      expect(page).to have_css '.attribute-subject[itemprop="about"] [itemprop="name"]', text: 'Oranges'
    end
    it "temporal -> temporalCoverage" do
      expect(page).to have_css '.attribute-temporal [itemprop="temporalCoverage"]', text: '1984-06-20'
    end
  end

  describe "schema.org markup on hidden/duplicated fields" do
    it "title -> name" do
      expect(page).to have_css '.attribute-title [itemprop="name"]', text: 'Example Work With Lots of Metadata Values'
    end
    it "description -> description" do
      expect(page).to have_css '.attribute-description [itemprop="description"]', text: /^Bicycle rights/
    end
    it "license -> license" do
      expect(page).to have_css '.attribute-license [itemprop="license"]', text: 'http://creativecommons.org/publicdomain/mark/1.0/'
    end
    it "RDR -> includedInDataCatalog" do
      expect(page).to have_css '[itemprop="includedInDataCatalog"] [itemprop="name"]', text: 'Duke Research Data Repository'
      expect(page).to have_css '[itemprop="includedInDataCatalog"] [itemprop="url"][content="https://research.repository.duke.edu"]'
    end
  end

end
