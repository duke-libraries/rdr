require 'rails_helper'
require 'importer'

RSpec.describe Importer::Factory::ObjectFactory do

  before(:all) do
    class TestModel < ActiveFedora::Base
      include Rdr::Metadata
    end
    class TestModelFactory < Importer::Factory::ObjectFactory
      self.klass = TestModel
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestModelFactory)
    Object.send(:remove_const, :TestModel)
  end

  describe '#find_by_ark' do
    subject { TestModelFactory.new({}) }
    let(:ark) { 'ark:/99999/fk4c256z6n' }
    describe 'object exists' do
      let!(:object) { TestModel.create(ark: ark) }
      it 'finds the object' do
        expect(subject.find_by_ark(ark)).to eq(object)
      end
    end
    describe 'object does not exist' do
      it 'returns nil' do
        expect(subject.find_by_ark(ark)).to be nil
      end
    end
    describe 'multiple objects found' do
      let!(:object) { TestModel.create(ark: ark) }
      let!(:additional_object) { TestModel.create(ark: ark) }
      it 'raises an error' do
        expect{ subject.find_by_ark(ark) }.to raise_error(Rdr::UnexpectedMultipleResultsError)
      end
    end
  end

  describe '#parent_id' do
    subject { TestModelFactory.new({ parent_ark: [ parent_ark ] }) }
    let(:parent_ark) { 'ark:/99999/fk4c256z6n' }
    describe 'parent exists' do
      let(:parent_repo_id) { '47429912h' }
      let(:parent) { TestModel.new(id: parent_repo_id) }
      before { allow(subject).to receive(:find_by_ark).with(parent_ark) { parent } }
      it 'returns the repository ID of the parent' do
        expect(subject.parent_id(parent_ark)).to eq(parent_repo_id)
      end
    end
    describe 'parent does not exist' do
      before { allow(subject).to receive(:find_by_ark).with(parent_ark) { nil } }
      it 'returns nil' do
        expect(subject.parent_id(parent_ark)).to be nil
      end
    end
  end
end
