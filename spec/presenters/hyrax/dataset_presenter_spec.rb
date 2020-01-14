# Generated via
#  `rails generate hyrax:work Dataset`
require 'rails_helper'

RSpec.describe Hyrax::DatasetPresenter do
  let(:solr_document) { SolrDocument.new }
  let(:request) { double(host: 'example.org') }
  let(:user) { FactoryBot.build(:user) }
  let(:ability) { Ability.new(user) }

  subject { described_class.new(solr_document, ability, request) }

  before do
    allow_any_instance_of(Collection).to receive(:mint_ark_for_collection) {}
  end

  describe '#doi_assignable?' do
    describe 'can assign/register DOIs' do
      before do
        ability.can :assign_register_doi, solr_document
      end
      it { is_expected.to be_assignable_doi }
    end
    describe 'cannot assign/register DOIs' do
      before do
        ability.cannot :assign_register_doi, solr_document
      end
      it { is_expected.to_not be_assignable_doi }
    end
  end

  describe '#grouped_work_presenters' do
    describe 'nested work' do
      let(:parent_doc) { SolrDocument.new('has_model_ssim' => 'Dataset') }
      let(:parent_work_presenter) { described_class.new(parent_doc, ability, request) }
      before do
        allow(subject).to receive(:in_work_presenters) { [ parent_work_presenter ] }
      end
      it 'has a work presenter for the datasets group' do
        expect(subject.grouped_work_presenters).to include('dataset' => [ parent_work_presenter ] )
      end
    end
  end

  describe '#in_work_presenters' do
    describe 'nested work' do
      let(:parent) { create(:dataset_with_one_child) }
      let(:child) { parent.ordered_works.first }
      subject { described_class.new(SolrDocument.find(child.id), ability, request) }
      it 'has a work presenter' do
        expect(subject.in_work_presenters).to include(an_instance_of(described_class))
      end
    end
  end

  describe '#toplevel_rdr_collection_presenters' do

    context 'work is top-level & in one RDR collection' do
      let(:collection) { build(:rdr_collection)}
      let(:work) { create(:public_dataset, member_of_collections: [collection])}
      before { allow(subject).to receive(:toplevel_work_id) { work.id } }
      it "returns the RDR collection presenter" do
        expect(subject.toplevel_rdr_collection_presenters.count).to eq 1
        expect(subject.toplevel_rdr_collection_presenters.first.collection_type.title).to eq "Collection"
        expect(subject.toplevel_rdr_collection_presenters.first.title).to include(/^RDR Collection Title/)
      end
    end

    context 'work is top-level, in 2 RDR collections, & 1 generic collection' do
      let(:collection_1) { build(:rdr_collection) }
      let(:collection_2) { build(:rdr_collection) }
      let(:collection_3) { build(:public_collection_lw) }
      let(:work) { create(:public_dataset, member_of_collections: [collection_1, collection_2, collection_3 ])}
      before { allow(subject).to receive(:toplevel_work_id) { work.id } }
      it "returns both RDR collection presenters, no others" do
        expect(subject.toplevel_rdr_collection_presenters.count).to eq 2
      end
    end

    context 'work is nested & its top-level ancestor is in an RDR collection' do
      let(:collection) { build(:rdr_collection) }
      let(:parent) { create(:dataset_with_one_child, member_of_collections: [collection]) }
      let(:work) { parent.ordered_works.first }
      before { allow(subject).to receive(:toplevel_work_id) { parent.id } }
      it "returns the top-level ancestor's RDR collection presenter" do
        expect(subject.toplevel_rdr_collection_presenters.first.collection_type.title).to eq "Collection"
        expect(subject.toplevel_rdr_collection_presenters.first.title).to include(/^RDR Collection Title/)
      end
    end

    context 'work is nested & its top level work is unknowable' do
      # happens if it or any ancestor dataset has more than one parent dataset
      let(:collection) { build(:rdr_collection) }
      let(:parent) { create(:dataset_with_one_child, member_of_collections: [collection]) }
      let(:work) { parent.ordered_works.first }
      before { allow(subject).to receive(:toplevel_work_id) { nil } }
      it "returns no collection presenters" do
        expect(subject.toplevel_rdr_collection_presenters).to eq []
        expect(subject.toplevel_rdr_collection_presenters.count).to eq 0
      end
    end
  end

  describe '#ancestor_trail' do
    context 'work is top-level (has no ancestors)' do
      let(:solr_document) { SolrDocument.new(id: 'abc', Rdr::Index::Fields.in_works_ids => []) }
      it 'returns an empty array' do
        expect(subject.ancestor_trail).to eq([])
      end
    end
    context 'work has multiple parent works' do
      let(:solr_document) { SolrDocument.new(id: 'abc', Rdr::Index::Fields.in_works_ids => ['def','ghi']) }
      it 'returns an empty array' do
        expect(subject.ancestor_trail).to eq([])
      end
    end
    context 'work has an ancestor with multiple parents' do
      let(:solr_document) { SolrDocument.new(id: 'abc', Rdr::Index::Fields.in_works_ids => ['def']) }
      let(:solr_document_parent) { SolrDocument.new( id: 'def', Rdr::Index::Fields.in_works_ids => ['ghi','jkl']) }
      before do
        allow(::SolrDocument).to receive(:find).with('def') { solr_document_parent }
      end
      it 'returns an empty array' do
        expect(subject.ancestor_trail).to eq([])
      end
    end
    context 'work has one ancestor' do
      let(:solr_document) { SolrDocument.new(id:'abc', Rdr::Index::Fields.in_works_ids => ['def']) }
      let(:solr_document_parent) { SolrDocument.new(id:'def', Rdr::Index::Fields.in_works_ids => []) }
      before do
        allow(::SolrDocument).to receive(:find).with('def').and_return(solr_document_parent)
      end
      it 'returns the ancestor document' do
        expect(subject.ancestor_trail).to eq([solr_document_parent])
      end
    end
    context 'work has a single trail of several ancestors' do
      let(:solr_document) { SolrDocument.new(id:'abc', Rdr::Index::Fields.in_works_ids => ['def']) }
      let(:solr_document_parent) { SolrDocument.new(id:'def', Rdr::Index::Fields.in_works_ids => ['ghi']) }
      let(:solr_document_grandparent) { SolrDocument.new(id:'ghi', Rdr::Index::Fields.in_works_ids => ['jkl']) }
      let(:solr_document_great_grandparent) { SolrDocument.new(id:'jkl', Rdr::Index::Fields.in_works_ids => []) }
      before do
        allow(::SolrDocument).to receive(:find).with('def').and_return(solr_document_parent)
        allow(::SolrDocument).to receive(:find).with('ghi').and_return(solr_document_grandparent)
        allow(::SolrDocument).to receive(:find).with('jkl').and_return(solr_document_great_grandparent)
      end
      it 'returns the ancestor document nodes' do
        expect(subject.ancestor_trail).to eq([ solr_document_great_grandparent, solr_document_grandparent, solr_document_parent ])
      end
    end
  end

end
