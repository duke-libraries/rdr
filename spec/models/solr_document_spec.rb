require 'rails_helper'

RSpec.describe SolrDocument do

  describe '#doi_assignable?' do
    let(:dataset_clause) { { 'has_model_ssim' => [ 'Dataset' ] } }
    let(:non_dataset_clause) { { 'has_model_ssim' => [ 'GenericWork' ] } }
    let(:ark_clause) { { Rdr::Index::Fields.ark => 'sample_ark' } }
    let(:doi_clause) { { Rdr::Index::Fields.doi => 'sample_doi' } }
    describe 'Dataset, ARK, no DOI' do
      subject { SolrDocument.new(dataset_clause.merge(ark_clause)) }
      it { is_expected.to be_doi_assignable }
    end
    describe 'not Dataset' do
      subject { SolrDocument.new(non_dataset_clause.merge(ark_clause)) }
      it { is_expected.to_not be_doi_assignable }
    end
    describe 'no ARK' do
      subject { SolrDocument.new(dataset_clause) }
      it { is_expected.to_not be_doi_assignable }
    end
    describe 'DOI' do
      subject { SolrDocument.new(dataset_clause.merge(doi_clause)) }
      it { is_expected.to_not be_doi_assignable }
    end
  end

end
