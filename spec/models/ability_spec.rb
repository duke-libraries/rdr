require 'rails_helper'
require 'cancan/matchers'

RSpec.describe 'Ability', type: :model do

  let!(:user) { FactoryBot.build(:user) }

  subject { Ability.new(user) }

  describe 'assign_register_doi' do
    before do
      allow_any_instance_of(Ability).to receive(:edit_groups) { [] }
      allow_any_instance_of(Ability).to receive(:edit_users) { [] }
    end

    describe 'dataset object' do
      let(:dataset) { FactoryBot.build(:dataset, id: 'test') }
      describe 'curator, editor, assignable, required metadata present' do
        before do
          allow(user).to receive(:curator?) { true }
          allow_any_instance_of(Ability).to receive(:edit_users) { [ user.user_key ] }
          allow(dataset).to receive(:doi_assignable?) { true }
          allow(dataset).to receive(:doi_required_metadata_present?) { true }
        end
        it { is_expected.to be_able_to(:assign_register_doi, dataset) }
      end
      describe 'not curator' do
        before do
          allow_any_instance_of(Ability).to receive(:edit_users) { [ user.user_key ] }
          allow(dataset).to receive(:doi_assignable?) { true }
          allow(dataset).to receive(:doi_required_metadata_present?) { true }
        end
        it { is_expected.to_not be_able_to(:assign_register_doi, dataset) }
      end
      describe 'not editor' do
        before do
          allow(user).to receive(:curator?) { true }
          allow(dataset).to receive(:doi_assignable?) { true }
          allow(dataset).to receive(:doi_required_metadata_present?) { true }
        end
        it { is_expected.to_not be_able_to(:assign_register_doi, dataset) }
      end
      describe 'not assignable' do
        before do
          allow(user).to receive(:curator?) { true }
          allow_any_instance_of(Ability).to receive(:edit_users) { [ user.user_key ] }
          allow(dataset).to receive(:doi_assignable?) { false }
          allow(dataset).to receive(:doi_required_metadata_present?) { true }
        end
        it { is_expected.to_not be_able_to(:assign_register_doi, dataset) }
      end
      describe 'required metadata not present' do
        before do
          allow(user).to receive(:curator?) { true }
          allow_any_instance_of(Ability).to receive(:edit_users) { [ user.user_key ] }
          allow(dataset).to receive(:doi_assignable?) { true }
          allow(dataset).to receive(:doi_required_metadata_present?) { false }
        end
        it { is_expected.to_not be_able_to(:assign_register_doi, dataset) }
      end
    end

    describe 'Solr document' do
      let(:doc) { SolrDocument.new }
      describe 'curator, editor, assignable, required metadata present' do
        before do
          allow(user).to receive(:curator?) { true }
          allow_any_instance_of(Ability).to receive(:edit_users) { [ user.user_key ] }
          allow(doc).to receive(:doi_assignable?) { true }
          allow(doc).to receive(:doi_required_metadata_present?) { true }
        end
        it { is_expected.to be_able_to(:assign_register_doi, doc) }
      end
      describe 'not curator' do
        before do
          allow_any_instance_of(Ability).to receive(:edit_users) { [ user.user_key ] }
          allow(doc).to receive(:doi_assignable?) { true }
          allow(doc).to receive(:doi_required_metadata_present?) { true }
        end
        it { is_expected.to_not be_able_to(:assign_register_doi, doc) }
      end
      describe 'not editor' do
        before do
          allow(user).to receive(:curator?) { true }
          allow(doc).to receive(:doi_assignable?) { true }
          allow(doc).to receive(:doi_required_metadata_present?) { true }
        end
        it { is_expected.to_not be_able_to(:assign_register_doi, doc) }
      end
      describe 'not assignable' do
        before do
          allow(user).to receive(:curator?) { true }
          allow_any_instance_of(Ability).to receive(:edit_users) { [ user.user_key ] }
          allow(doc).to receive(:doi_assignable?) { false }
          allow(doc).to receive(:doi_required_metadata_present?) { true }
        end
        it { is_expected.to_not be_able_to(:assign_register_doi, doc) }
      end
      describe 'required metadata not present' do
        before do
          allow(user).to receive(:curator?) { true }
          allow_any_instance_of(Ability).to receive(:edit_users) { [ user.user_key ] }
          allow(doc).to receive(:doi_assignable?) { true }
          allow(doc).to receive(:doi_required_metadata_present?) { false }
        end
        it { is_expected.to_not be_able_to(:assign_register_doi, doc) }
      end
    end
  end

  describe 'batch imports' do

    describe 'user is a curator' do

      before do
        allow(user).to receive(:curator?) { true }
      end

      it { is_expected.to be_able_to(:create, BatchImport) }

    end

    describe 'user is not a curator' do
      it { is_expected.to_not be_able_to(:create, BatchImport) }
    end

  end

  describe 'create collections' do
    describe 'registered user' do
      before { allow(user).to receive(:groups) { [ 'registered' ] } }
      it { is_expected.to be_able_to(:create, Collection) }
    end
  end

  describe 'create works' do
    describe 'user is a curator' do
      before do
        allow(user).to receive(:curator?) { true }
      end
      it { is_expected.to be_able_to(:create, Dataset) }
    end

    describe 'user is not a curator' do
      it { is_expected.to_not be_able_to(:create, Dataset) }
    end
  end

  describe 'create submissions' do
    describe 'logged in' do
      before { allow(user).to receive(:groups) { [ 'registered' ] } }
      it { is_expected.to be_able_to(:create, Submission) }
    end
    describe 'not logged in' do
      it { is_expected.to_not be_able_to(:create, Submission) }
    end
  end

end
