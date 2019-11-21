require 'rails_helper'

RSpec.describe DatasetIndexer do
  subject(:solr_document) { service.generate_solr_document }
  let(:service) { described_class.new(work) }
  let(:work) { build(:dataset) }

  context 'with at least one parent work' do
    before { allow(work).to receive(:in_works_ids).and_return(["t148fh12j"]) }
    it 'indexes as not a top-level work' do
      expect(solr_document[Rdr::Index::Fields.top_level]).to eq false
    end
    it 'indexes the parent work IDs' do
      expect(solr_document[Rdr::Index::Fields.in_works_ids]).to eq ["t148fh12j"]
    end
  end

  context 'with no parent work' do
    before { allow(work).to receive(:in_works_ids).and_return([]) }
    it 'indexes as a top-level work' do
      expect(solr_document[Rdr::Index::Fields.top_level]).to eq true
    end
    it 'does not index parent work IDs' do
      expect(solr_document[Rdr::Index::Fields.in_works_ids]).to be_blank
    end
  end

  context 'with Publication Date (available)' do
    before { allow(work).to receive(:available).and_return(["2019-11-21"]) }
    it 'indexes years' do
      expect(solr_document[Rdr::Index::Fields.pub_year]).to eq [2019]
    end
  end

  context 'with Publication Date (available) using EDTF fuzzy syntax' do
    before { allow(work).to receive(:available).and_return(["201X"]) }
    it 'indexes each year in range' do
      expect(solr_document[Rdr::Index::Fields.pub_year]).to match_array((2010..2019).to_a)
    end
  end

  context 'with missing Publication Date (available)' do
    before { allow(work).to receive(:available).and_return(nil) }
    it 'does not index years' do
      expect(solr_document[Rdr::Index::Fields.pub_year]).to eq []
    end
  end
end
