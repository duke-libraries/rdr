# Generated via
#  `rails generate hyrax:work Dataset`
require 'rails_helper'

RSpec.describe Hyrax::DatasetPresenter do
  let(:solr_document) { SolrDocument.new }
  let(:request) { double(host: 'example.org') }
  let(:user) { FactoryBot.build(:user) }
  let(:ability) { Ability.new(user) }

  subject { described_class.new(solr_document, ability, request) }

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

end
