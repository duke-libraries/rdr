require 'rails_helper'

RSpec.describe DatasetIndexer do
  subject(:solr_document) { service.generate_solr_document }
  let(:service) { described_class.new(work) }
  let(:work) { create(:dataset) }

  context 'with at least one parent work' do
    before { allow(work).to receive(:in_works_ids).and_return(["t148fh12j"]) }
    it 'indexes as not a top-level work' do
      expect(solr_document['top_level_bsi']).to eq false
    end
  end

  context 'with no parent work' do
    before { allow(work).to receive(:in_works_ids).and_return([]) }
    it 'indexes as a top-level work' do
      expect(solr_document['top_level_bsi']).to eq true
    end
  end

end
