require 'rails_helper'
require 'ezid-client'

RSpec.describe Ark do

  describe 'constructor' do
    describe 'when the object is new' do
      let(:obj) { FactoryBot.build(:dataset) }
      it 'raises an error' do
        expect{ described_class.new(obj) }.to raise_error(Ark::RepoObjectNotPersisted)
      end
    end
    describe 'when passed a repo object id' do
      let(:obj) { FactoryBot.create(:dataset) }
      subject { described_class.new(obj.id) }
      its(:repo_id) { is_expected.to eq(obj.id) }
    end
  end

  describe 'instance methods' do
    let(:obj) { FactoryBot.create(:dataset) }
    subject { described_class.new(obj) }

    describe '#publish!' do
      let!(:id) { described_class.identifier_class.new("foo") }
      before do
        allow(subject).to receive(:identifier) { id }
        allow(id).to receive(:save) { nil }
      end
      it 'sets the ARK status to public' do
        subject.publish!
        expect(id.status).to eq(Ezid::Status::PUBLIC)
      end
    end

    describe '#assign' do
      describe 'when the object already has an ARK' do
        before { obj.ark = "foo" }
        it "raises an error" do
          expect { subject.assign! }.to raise_error(Ark::AlreadyAssigned)
          expect { subject.assign!("bar") }.to raise_error(Ark::AlreadyAssigned)
        end
      end
      describe 'when the object does not have an ARK' do
        let(:obj) { FactoryBot.create(:dataset) }
        let!(:id) { described_class.identifier_class.new("foo") }
        before do
          allow(described_class.identifier_class).to receive(:find).with('foo') { id }
          allow(id).to receive(:save) { nil }
          allow(obj).to receive(:save) { true }
        end
        describe 'when passed an ARK' do
          before do
            subject.assign!('foo')
          end
          it "assigns the ARK" do
            expect(obj.ark).to eq('foo')
          end
          it 'sets the status on the identifier' do
            expect(id.status).to eq(Ezid::Status::RESERVED)
          end
        end
        describe 'when not passed an ARK' do
          before do
            allow(described_class.identifier_class).to receive(:mint) { id }
            subject.assign!
          end
          it 'mints and assigns an ARK' do
            expect(obj.ark).to eq('foo')
          end
          it 'sets the status on the identifier' do
            expect(id.status).to eq(Ezid::Status::RESERVED)
          end
        end
      end
    end

    describe '#deactivate!' do
      let!(:id) { described_class.identifier_class.new("foo") }
      before do
        allow(subject).to receive(:identifier) { id }
        allow(id).to receive(:persisted?) { true }
        allow(id).to receive(:public?) { true }
        allow(id).to receive(:save)
      end
      it 'marks the ARK as unavailable with a reason' do
        expect(id).to receive(:unavailable!).with(Rdr.deaccession_reason)
        subject.deactivate!
      end
    end

    describe '#delete!' do
      let!(:id) { described_class.identifier_class.new("foo") }
      before do
        allow(subject).to receive(:identifier) { id }
        allow(id).to receive(:persisted?) { true }
      end
      it 'deletes the ARK' do
        expect(id).to receive(:delete)
        subject.delete!
      end
    end
  end
end
