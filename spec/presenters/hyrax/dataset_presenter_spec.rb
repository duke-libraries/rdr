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
end
