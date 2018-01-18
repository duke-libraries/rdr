require 'rails_helper'
require 'importer'

RSpec.describe Importer::Factory::DatasetFactory, :clean do
  let(:factory) { described_class.new(attributes) }
  let(:actor) { double }
  let(:files_directory) { fixture_path }
  let(:files) { [] }
  let(:attributes) do
    {
        collection: { id: coll.id },
        file: files,
        identifier: ['123'],
        title: ['Test dataset'],
        read_groups: ['public'],
        depositor: 'bob',
        edit_users: ['bob']
    }
  end

  before do
    allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
  end

  context 'with files' do
    let(:factory) { described_class.new(attributes, files_directory) }
    let(:files) { ['data.csv'] }
    let(:file_path) { File.join(files_directory, files.first) }
    let(:uploaded_file) { double(Hyrax::UploadedFile, id: 7) }
    let!(:coll) { create(:collection) }

    before do
      allow(Hyrax::UploadedFile).to receive(:create) { uploaded_file }
    end

    context "for a new dataset" do
      it 'creates file sets with access controls' do
        expect(actor).to receive(:create).with(Hyrax::Actors::Environment) do |k|
          expect(k.attributes).to include('member_of_collection_ids' => [ coll.id ],
                                          'uploaded_files' => [ uploaded_file.id ])
        end
        factory.run
      end
    end

    context "for an existing dataset without files" do
      let(:work) { create(:dataset) }
      let(:factory) { described_class.new(attributes.merge(id: work.id), files_directory) }
      it 'creates file sets' do
        expect(actor).to receive(:update).with(Hyrax::Actors::Environment) do |k|
          expect(k.attributes).to include('member_of_collection_ids' => [ coll.id ],
                                          'uploaded_files' => [ uploaded_file.id ])
        end
        factory.run
      end
    end
  end

  context 'when a collection already exists' do
    let!(:coll) { create(:collection) }

    it 'does not create a new collection' do
      expect(actor).to receive(:create).with(Hyrax::Actors::Environment) do |k|
        expect(k.attributes).to include(member_of_collection_ids: [coll.id])
      end
      expect do
        factory.run
      end.to change { Collection.count }.by(0)
    end
  end
end
