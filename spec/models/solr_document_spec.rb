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

  describe '#doi_required_metadata_present?' do
    let(:title_clause) { { Rdr::Index::Fields.title => [ 'Test Title' ] } }
    let(:creator_clause) { { Rdr::Index::Fields.creator => [ 'Creator, Carl' ] } }
    let(:available_clause) { { Rdr::Index::Fields.available => [ '2018-02-02T00:00:00Z' ] } }
    describe 'title, creator, available date' do
      subject { SolrDocument.new(title_clause.merge(creator_clause).merge(available_clause)) }
      it { is_expected.to be_doi_required_metadata_present }
    end
    describe 'no title' do
      subject { SolrDocument.new(creator_clause.merge(available_clause)) }
      it { is_expected.to_not be_doi_required_metadata_present }
    end
    describe 'no creator' do
      subject { SolrDocument.new(title_clause.merge(available_clause)) }
      it { is_expected.to_not be_doi_required_metadata_present }
    end
    describe 'no available date' do
      subject { SolrDocument.new(title_clause.merge(creator_clause)) }
      it { is_expected.to_not be_doi_required_metadata_present }
    end
  end

end
