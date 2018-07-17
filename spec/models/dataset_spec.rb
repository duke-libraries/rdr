# Generated via
#  `rails generate hyrax:work Dataset`
require 'rails_helper'
require 'cancan/matchers'
require 'ezid/test_helper'

RSpec.describe Dataset do

  context "object creation", integration: true do
    subject do
      Hyrax::CurationConcern.actor.create(env)
      Dataset.find('test_work')
    end

    let!(:depositor) { FactoryBot.create(:user) }
    let(:remote_file) { File.join(fixture_path, "data.csv") }
    let(:remote_files) { { url: "file:#{remote_file}", file_name: File.basename(remote_file) } }
    let(:attrs) { { title: ['test work'], depositor: depositor.user_key, remote_files: [remote_files] } }
    let(:ability) { Ability.new(depositor) }
    let(:env) {
      Hyrax::Actors::Environment.new(Dataset.new(id: 'test_work'),
                                     ability,
                                     attrs)
    }

    before do
      ezid_test_mode!
      allow(CharacterizeJob).to receive(:perform_later)
    end

    context "depositor is not a curator" do
      it "grants the depositor read rights on the work" do
        expect(ability).to_not be_able_to(:edit, subject)
        expect(ability).to be_able_to(:read, subject)
      end

      it "grants the depositor read rights on the work filesets" do
        expect(ability).to_not be_able_to(:edit, subject.file_sets.first)
        expect(ability).to be_able_to(:read, subject.file_sets.first)
      end
    end

    context "depositor is a curator" do
      before do
        allow(User).to receive(:curators).and_return([ depositor.user_key ])
      end

      it "grants the depositor edit rights on the work" do
        expect(ability).to be_able_to(:edit, subject)
      end

      it "grants the depositor edit rights on the work filesets" do
        expect(ability).to be_able_to(:edit, subject.file_sets.first)
      end
    end

    context "nested work" do
      let(:parent) { FactoryBot.create(:dataset, user: depositor) }
      let(:attrs) { { title: ['test work'], depositor: depositor.user_key, in_works_ids: [ parent.id ] } }
      before do
        allow(User).to receive(:curators).and_return([ depositor.user_key ])
      end
      it "is not indexed as top level" do
        expect(SolrDocument.find(subject.id).top_level).to be false
      end
    end
  end

  describe "#latest_dataset_version?" do
    subject { FactoryBot.build(:dataset, doi: "http://example.com/my_doi_v1") }
    describe "when isReplacedBy is blank" do
      it { is_expected.to be_latest_dataset_version }
    end
    describe "when isReplacedBy is present" do
      before { subject.is_replaced_by = "http://example.com/my_doi_v2" }
      it { is_expected.not_to be_latest_dataset_version }
    end
  end

  describe "#has_next_dataset_version?" do
    subject { FactoryBot.build(:dataset, doi: "http://example.com/my_doi_v1") }
    describe "when isReplacedBy is blank" do
      it { is_expected.not_to have_next_dataset_version }
    end
    describe "when isReplacedBy is present" do
      before { subject.is_replaced_by = "http://example.com/my_doi_v2" }
      it { is_expected.to have_next_dataset_version }
    end
  end

  describe "#next_dataset_version" do
    subject { FactoryBot.build(:dataset, doi: "http://example.com/my_doi_v1") }
    describe "when isReplacedBy is blank" do
      its(:next_dataset_version) { is_expected.to be_nil }
    end
    describe "when isReplacedBy is present" do
      let!(:v2) { FactoryBot.create(:dataset, doi: "http://example.com/my_doi_v2", replaces: "http://example.com/my_doi_v1") }
      before { subject.is_replaced_by = "http://example.com/my_doi_v2" }
      it "returns the next version" do
        expect(subject.next_dataset_version.id).to eq(v2.id)
      end
    end
  end

  describe "#has_previous_dataset_version?" do
    describe "when replaces is blank" do
      subject { FactoryBot.build(:dataset, doi: "http://example.com/my_doi_v1") }
      it { is_expected.not_to have_previous_dataset_version }
    end
    describe "when replaces is present" do
      subject { FactoryBot.build(:dataset, doi: "http://example.com/my_doi_v2", replaces: "http://example.com/my_doi_v1") }
      it { is_expected.to have_previous_dataset_version }
    end
  end

  describe "#previous_dataset_version" do
    describe "when replaces is blank" do
      subject { FactoryBot.build(:dataset, doi: "http://example.com/my_doi_v1") }
      its(:previous_dataset_version) { is_expected.to be_nil }
    end
    describe "when replaces is present" do
      let!(:v1) { FactoryBot.create(:dataset, doi: "http://example.com/my_doi_v1", is_replaced_by: "http://example.com/my_doi_v2") }
      subject { FactoryBot.create(:dataset, doi: "http://example.com/my_doi_v2", replaces: "http://example.com/my_doi_v1") }
      it "returns the previous version" do
        expect(subject.previous_dataset_version.id).to eq(v1.id)
      end
    end
  end

  describe "#latest_dataset_version" do
    describe "when isReplacedBy is blank" do
      subject { FactoryBot.build(:dataset, doi: "http://example.com/my_doi_v1") }
      its(:latest_dataset_version) { is_expected.to eq subject }
    end
    describe "when isReplacedBy is present" do
      subject { FactoryBot.create(:dataset, doi: "http://example.com/my_doi_v1", is_replaced_by: "http://example.com/my_doi_v2") }
      describe "and no other record has that DOI" do
        it "raises an error" do
          expect { subject.latest_dataset_version }.to raise_error(Rdr::DatasetVersionError)
        end
      end
      describe "and another record has that DOI" do
        describe "and isReplacedBy for the other record is blank" do
          let!(:v2) { FactoryBot.create(:dataset, doi: "http://example.com/my_doi_v2", replaces: "http://example.com/my_doi_v1") }
          it "returns the other record" do
            expect(subject.latest_dataset_version.id).to eq v2.id
          end
        end
        describe "and isReplacedBy for the other record is present" do
          let!(:v2) { FactoryBot.create(:dataset, doi: "http://example.com/my_doi_v2", replaces: "http://example.com/my_doi_v1", is_replaced_by: "http://example.com/my_doi_v3") }
          let!(:v3) { FactoryBot.create(:dataset, doi: "http://example.com/my_doi_v3", replaces: "http://example.com/my_doi_v2") }
          it "does not return the other record" do
            expect(subject.latest_dataset_version.id).not_to eq v2.id
          end
        end
      end
    end
  end

  describe "#dataset_versions" do
    let!(:v1) { FactoryBot.create(:dataset, doi: "http://example.com/my_doi_v1", is_replaced_by: "http://example.com/my_doi_v2") }
    let!(:v2) { FactoryBot.create(:dataset, doi: "http://example.com/my_doi_v2", replaces: "http://example.com/my_doi_v1", is_replaced_by: "http://example.com/my_doi_v3") }
    let!(:v3) { FactoryBot.create(:dataset, doi: "http://example.com/my_doi_v3", replaces: "http://example.com/my_doi_v2") }
    it "returns all 3 versions for v1" do
      expect(v1.dataset_versions).to eq [v1, v2, v3]
    end
    it "returns all 3 versions for v2" do
      expect(v2.dataset_versions).to eq [v1, v2, v3]
    end
    it "returns all 3 versions for v3" do
      expect(v3.dataset_versions).to eq [v1, v2, v3]
    end
    describe "reloading the dataset" do
      it "resets the @dataset_versions instance variable to nil" do
        v1.dataset_versions
        expect { v1.reload }.to change { v1.instance_variable_get("@dataset_versions") }.to(nil)
      end
    end
  end

  describe "#doi_assignable?" do
    describe "has ARK" do
      describe "has DOI" do
        subject { FactoryBot.build(:dataset, ark: 'sample_ark', doi: 'sample_doi') }
        it { is_expected.not_to be_doi_assignable }
      end
      describe "does not have DOI" do
        subject { FactoryBot.build(:dataset, ark: 'sample_ark') }
        it { is_expected.to be_doi_assignable }
      end
    end
    describe "does not have ARK" do
      describe "has DOI" do
        subject { FactoryBot.build(:dataset, doi: 'sample_doi') }
        it { is_expected.not_to be_doi_assignable }
      end
      describe "does not have DOI" do
        subject { FactoryBot.build(:dataset) }
        it { is_expected.not_to be_doi_assignable }
      end
    end
  end

  describe "#doi_required_metadata_present?" do
    subject { FactoryBot.build(:dataset, title: [ 'Test' ], creator: [ 'Smith, Joe' ], available: [ '2018-02-02' ]) }
    describe "has title, creator, available" do
      it { is_expected.to be_doi_required_metadata_present }
    end
    describe "does not have a title" do
      before { allow(subject).to receive(:title) { [] } }
      it { is_expected.not_to be_doi_required_metadata_present }
    end
    describe "does not have a creator" do
      before { allow(subject).to receive(:creator) { [] } }
      it { is_expected.not_to be_doi_required_metadata_present }
    end
    describe "does not have an available date" do
      before { allow(subject).to receive(:available) { [] } }
      it { is_expected.not_to be_doi_required_metadata_present }
    end
  end

  describe "#doi_registerable?" do
    subject { FactoryBot.build(:dataset, ark: 'sample_ark', doi: 'sample_doi') }
    before { allow(subject).to receive(:doi_required_metadata_present?) { true } }
    describe "has ARK, DOI, required metadata present" do
      it { is_expected.to be_doi_registerable }
    end
    describe "does not have ARK" do
      before { allow(subject).to receive(:ark) { nil } }
      it { is_expected.not_to be_doi_registerable }
    end
    describe "does not have DOI" do
      before { allow(subject).to receive(:doi) { nil } }
      it { is_expected.not_to be_doi_registerable }
    end
    describe "does not have required metadata" do
      before { allow(subject).to receive(:doi_required_metadata_present?) { false } }
      it { is_expected.not_to be_doi_registerable }
    end
  end

  describe "dataset update" do
    describe "dataset nesting", integration: true do
      let!(:user) { FactoryBot.create(:user) }
      let!(:datasets) { FactoryBot.create_list(:dataset, 2, user: user) }
      let(:ability) { Ability.new(user) }
      let(:env) { Hyrax::Actors::Environment.new(datasets[0], ability, attrs) }

      before do
        allow(User).to receive(:curators) { [ user.user_key ] }
        datasets.each do |ds|
          ds.edit_users += [ user.user_key ]
          ds.save!
        end
      end

      describe "nest existing top-level dataset within another dataset" do
        let(:attrs) { { title: [ datasets[0].title.first ],
                        depositor: user.user_key,
                        work_members_attributes: { "0"=>{ "id"=>"#{datasets[1].id}", "_destroy"=>"false" } } } }
        specify "the newly nested work is not indexed as top-level" do
          Hyrax::CurationConcern.actor.update(env)
          expect(SolrDocument.find(datasets[1].id).top_level).to be false
        end
      end

      describe "remove nested dataset so that it is now top-level" do
        let(:attrs) { { title: [ datasets[0].title.first ],
                        depositor: user.user_key,
                        work_members_attributes: { "0"=>{ "id"=>"#{datasets[1].id}", "_destroy"=>"true" } } } }
        before do
          datasets[0].ordered_members << datasets[1]
          datasets[0].save!
          datasets[1].update_index
        end
        specify "the newly unnested work is indexed as top-level" do
          Hyrax::CurationConcern.actor.update(env)
          expect(SolrDocument.find(datasets[1].id).top_level).to be true
        end
      end
    end
  end

end
