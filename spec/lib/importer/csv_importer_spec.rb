require 'rails_helper'
require 'importer'
require 'ezid/test_helper'

module Importer
  RSpec.describe CSVImporter do
    let(:files_directory) { '/tmp/files' }

    describe 'batch object import' do
      subject { described_class.new(csv_file, files_directory) }
      let(:csv_file) { "#{fixture_path}/importer/manifest_samples/sample.csv" }
      before do
        allow(subject).to receive(:parser) { parser }
      end
      describe 'object has no ARK' do
        let(:attributes) { { title: [ 'Test' ] } }
        let(:parser) { double('Importer::CSVParser') }
        it 'imports the object later' do
          expect(BatchObjectImportJob).to receive(:perform_later).with(subject.model, attributes, files_directory)
          subject.import_batch_object(attributes)
        end
      end
      describe 'object has an ARK' do
        let(:ark) { 'ark:/99999/fk4cg0xp0k' }
        let(:attributes) { { ark: [ ark ], title: [ 'Test' ] } }
        describe 'ARK is parent ARK' do
          let(:parser) { double('Importer::CSVParser', parent_arks: [ ark ]) }
          it 'imports the object now' do
            expect(BatchObjectImportJob).to receive(:perform_now).with(subject.model, attributes, files_directory)
            subject.import_batch_object(attributes)
          end
        end
        describe 'ARK is not parent ARK' do
          let(:parser) { double('Importer::CSVParser', parent_arks: [ ]) }
          it 'imports the object later' do
            expect(BatchObjectImportJob).to receive(:perform_later).with(subject.model, attributes, files_directory)
            subject.import_batch_object(attributes)
          end
        end
      end
    end

    describe 'checksums' do
      let(:csv_file) { "#{fixture_path}/importer/manifest_samples/sample.csv" }
      before do
        allow(subject).to receive(:parser) { [] }
      end
      describe 'checksum file provided' do
        subject { described_class.new(csv_file, files_directory, checksum_file: checksum_file) }
        let(:checksum_file) { File.join(fixture_path, 'importer', 'checksums.txt') }
        it 'loads the provided checksums' do
          expect{ subject.import_all }.to change{ Checksum.count }.by(3)
        end
      end
      describe 'checksum file not provided' do
        subject { described_class.new(csv_file, files_directory) }
        it 'does not load checksums' do
          expect{ subject.import_all }.to_not change{ Checksum.count }
        end
      end
    end

    describe 'deposit attributes' do
      let(:csv_file) { "/tmp/manifest.csv" }
      let(:depositor_key) { 'a@b.edu' }
      before do
        allow(subject).to receive(:parser) { [ {'title' => [ 'Test Title' ] } ] }
      end
      subject { described_class.new(csv_file, files_directory, model: 'Dataset', depositor: depositor_key ) }
      before do
        allow_any_instance_of(Importer::Factory::DatasetFactory).to receive(:run)
      end
      it 'passes the depositor and proxy depositor to the object factory' do
        expect(Importer::Factory::DatasetFactory).to receive(:new)
                                                      .with(hash_including(depositor: depositor_key),
                                                            any_args)
                                                      .and_call_original
        subject.import_all
      end
    end

    context 'end-to-end integration', integration: true do
      let(:tmp_dir) { Dir.mktmpdir }
      let(:manifest_file_template) { File.join(fixture_path, 'importer', 'dataset', 'manifest.csv') }
      let(:manifest_file) { File.join(tmp_dir, 'manifest.csv') }
      let(:files_directory) { File.join(fixture_path, 'importer', 'dataset', 'files') }
      let(:checksum_file_template) { File.join(fixture_path, 'importer', 'dataset', 'checksums.txt') }
      let(:checksum_file) { File.join(tmp_dir, 'checksums.txt') }
      let(:model) { 'Dataset' }
      let!(:depositor) { FactoryBot.create(:user) }
      let(:on_behalf_of) { FactoryBot.create(:user) }
      let(:dataset_titles) { [ [ 'Test 1' ], [ 'Test 2' ], [ 'Test 3' ] ] }
      let(:ds1_checksums) { [ '4c4665b408134d8f6995d1640a7f2d4eeee5c010', 'ab84c8b1187123c4d627bea511714dd723b56dbe', '94631dfa806987fa6c01880d59303519f23c5609' ] }
      let(:ds2_checksums) { [ '37a0502601ed54f31d119d5355ade2c29ea530ea', '8376ba1d652cee933cc7cff95d8c049fb7a9a855' ] }
      let(:ds3_checksums) { [ '4c4665b408134d8f6995d1640a7f2d4eeee5c010' ] }
      let(:parent_ark) { Ezid::Identifier.mint }
      subject { described_class.new(manifest_file, files_directory, model: model, checksum_file: checksum_file,
                                    depositor: depositor.user_key) }
      before do
        ezid_test_mode!
        AdminSet.find_or_create_default_admin_set_id
        allow(User).to receive(:curators) { [ depositor.user_key ] }
        allow(CharacterizeJob).to receive(:perform_later)
        manifest_template = File.read(manifest_file_template)
        manifest_data = manifest_template.gsub('PARENT_ARK', parent_ark.id).gsub('ON_BEHALF_OF', on_behalf_of.user_key)
        File.open(manifest_file, 'w') do |f|
          f.write(manifest_data)
        end
        checksum_template = File.read(checksum_file_template)
        checksum_data = checksum_template.gsub('FIXTURE_PATH', fixture_path)
        File.open(checksum_file, 'w') do |f|
          f.write(checksum_data)
        end
        stub_request(:get, "http://sws.geonames.org/4464368/").
            with(  headers: {
                'Accept'=>'text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/ld+json, application/x-ld+json, application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, application/normalized+n-quads, application/x-normalized+n-quads, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig;q=0.2, application/trix',
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent'=>'Ruby'
            }).
            to_return(status: 200, body: "", headers: {})
        stub_request(:get, "http://sws.geonames.org/4460162/").
            with(  headers: {
                'Accept'=>'text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/ld+json, application/x-ld+json, application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, application/normalized+n-quads, application/x-normalized+n-quads, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig;q=0.2, application/trix',
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent'=>'Ruby'
            }).
            to_return(status: 200, body: "", headers: {})
      end
      after { FileUtils.rmdir(tmp_dir)}
      it 'imports the objects' do
        subject.import_all
        datasets = Dataset.all
        expect(datasets.size).to eq(3)
        expect(datasets.map(&:admin_set).map(&:id)).to all(eq(AdminSet::DEFAULT_ID))
        expect(datasets.map(&:depositor)).to all(eq(on_behalf_of.user_key))
        expect(datasets.map(&:on_behalf_of)).to all(eq(on_behalf_of.user_key))
        expect(datasets.map(&:proxy_depositor)).to all(eq(depositor.user_key))
        expect(datasets.map(&:title)).to match_array(dataset_titles)
        expect(datasets.map(&:ark)).to all(be_a(String))
        datasets.map(&:ark).each do |ark|
          ark_id_obj = Ezid::Identifier.find(ark)
          url = ["https://", Rdr.host_name, '/id/', ark_id_obj.id ].join
          expect(ark_id_obj.status).to eq(Ezid::Status::PUBLIC)
          expect(ark_id_obj.target).to eq(url)
        end
        ds1 = Dataset.where(title: 'Test 1').first
        ds2 = Dataset.where(title: 'Test 2').first
        ds3 = Dataset.where(title: 'Test 3').first
        expect(ds1.works).to match_array([ ds2, ds3 ])
        expect(ds2.in_works).to eq([ ds1 ])
        expect(ds3.in_works).to eq([ ds1 ])
        expect(SolrDocument.find(ds1.id).top_level).to be true
        expect(SolrDocument.find(ds2.id).top_level).to be false
        expect(SolrDocument.find(ds3.id).top_level).to be false
        expect(ds1.visibility).to eq(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
        expect(ds2.visibility).to eq(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE)
        expect(ds3.visibility).to eq(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED)
        expect(ds1.based_near).to contain_exactly(an_instance_of(Hyrax::ControlledVocabularies::Location),
                                                  an_instance_of(Hyrax::ControlledVocabularies::Location))
        expect(ds2.based_near).to be_empty
        expect(ds3.based_near).to be_empty
        expect(ds1.file_sets.map(&:files).map(&:first).map(&:checksum).map(&:value)).to match_array(ds1_checksums)
        expect(ds2.file_sets.map(&:files).map(&:first).map(&:checksum).map(&:value)).to match_array(ds2_checksums)
        expect(ds3.file_sets.map(&:files).map(&:first).map(&:checksum).map(&:value)).to match_array(ds3_checksums)
      end
    end

  end
end
