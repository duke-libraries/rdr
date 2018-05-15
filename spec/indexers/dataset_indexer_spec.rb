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

end
