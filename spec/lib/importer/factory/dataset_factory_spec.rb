require 'rails_helper'
require 'importer'

RSpec.describe Importer::Factory::DatasetFactory, :clean do
  let(:factory) { described_class.new(attributes) }
  let(:actor) { double }
  let(:files_directory) { fixture_path }
  let(:files) { [] }
  let(:depositor_key) { 'a@b.edu' }
  let(:proxy_key) { 'c@d.edu' }
  let(:attributes) do
    {
        collection_id: [ coll.id ],
        file: files,
        identifier: ['123'],
        title: ['Test dataset'],
        read_groups: ['public'],
        depositor: depositor_key,
        edit_users: ['bob'],
        proxy_depositor: proxy_key
    }
  end

  before do
    allow(Hyrax).to receive(:config).and_call_original
    allow(Hyrax).to receive_message_chain(:config, :whitelisted_ingest_dirs) { Array(fixture_path) }
    allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
  end

  context 'with files' do
    let(:factory) { described_class.new(attributes, files_directory) }
    let(:files) { ['data.csv'] }
    let(:file_path) { File.join(files_directory, files.first) }
    let(:remote_files) { [ { url: "file:#{file_path}", file_name: files.first } ] }
    let!(:coll) { create(:collection) }

    context "for a new dataset" do
      describe "admin set" do
        describe "admin set ID provided" do
          let(:expected_admin_set_id) { 'w9505044z' }
          before { attributes.merge!({ admin_set_id: expected_admin_set_id }) }
          it 'creates file sets with provided admin set' do
            expect(actor).to receive(:create).with(Hyrax::Actors::Environment) do |k|
              expect(k.attributes).to include('member_of_collection_ids' => [ coll.id ],
                                              'remote_files' => remote_files,
                                              'admin_set_id' => expected_admin_set_id)
            end
            factory.run
          end
        end
        describe "admin set ID not provided" do
          it 'creates file sets without specified admin set' do
            expect(actor).to receive(:create).with(Hyrax::Actors::Environment) do |k|
              expect(k.attributes).to include('member_of_collection_ids' => [ coll.id ],
                                              'remote_files' => remote_files)
            end
            factory.run
          end
        end
      end
      describe "nesting" do
        describe "parent ARK provided" do
          let(:parent_ark) { 'ark:/99999/fk4c256z6n' }
          let(:parent_id) { 'gq67jr16q' }
          before do
            attributes.merge!({ parent_ark: [ parent_ark ] })
            allow(factory).to receive(:parent_id).with(parent_ark) { parent_id }
          end
          it 'sends the appropriate nesting attribute to the actor' do
            expect(actor).to receive(:create).with(Hyrax::Actors::Environment) do |k|
              expect(k.attributes).to include('in_works_ids' => [ parent_id ])
            end
            factory.run
          end
        end
      end
      describe "deposit attributes" do
        it 'sends the appropriate deposit attributes to the actor' do
          expect(actor).to receive(:create).with(Hyrax::Actors::Environment) do |k|
            expect(k.attributes).to include('depositor' => depositor_key, 'proxy_depositor' => proxy_key)
          end
          factory.run
        end
      end
    end

  end

end
