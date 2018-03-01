require 'rails_helper'
require 'importer'

module Importer
  RSpec.describe CSVImporter do
    let(:files_directory) { '/tmp/files' }

    context 'when the model is passed' do
      let(:csv_file) { "#{fixture_path}/importer/metadata_samples/some_implicit_models.csv" }
      let(:importer) { described_class.new(csv_file, files_directory, fallback_class) }
      let(:fallback_class) { Class.new { def initialize(_x, _y); end } }
      let(:factory) { double(run: true) }

      # note: 1 row does not specify type, 2 do
      it 'creates new works' do
        expect(fallback_class).to receive(:new)
                                      .with(any_args).and_return(factory).exactly(1).times
        expect(Importer::Factory::DatasetFactory).to receive(:new)
                                                         .with(any_args).and_return(factory).exactly(2).times
        importer.import_all
      end
    end

    context 'when the model specified on the row' do
      let(:csv_file) { "#{fixture_path}/importer/metadata_samples/explicit_models.csv" }
      let(:importer) { described_class.new(csv_file, files_directory) }
      let(:collection_factory) { double }
      let(:dataset_factory) { double }

      it 'creates new datasets and collections' do
        expect(Importer::Factory::CollectionFactory).to receive(:new)
                                                            .with(hash_excluding(:type), files_directory)
                                                            .and_return(collection_factory)
        expect(collection_factory).to receive(:run)
        expect(Importer::Factory::DatasetFactory).to receive(:new)
                                                         .with(hash_excluding(:type), files_directory)
                                                         .and_return(dataset_factory).exactly(3).times
        expect(dataset_factory).to receive(:run).exactly(3).times
        importer.import_all
      end
    end

    describe 'checksums' do
      let(:csv_file) { "#{fixture_path}/importer/metadata_samples/explicit_models.csv" }
      before do
        allow(subject).to receive(:parser) { [] }
      end
      describe 'checksum file provided' do
        subject { described_class.new(csv_file, files_directory, nil, checksum_file) }
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

    context 'end-to-end integration', integration: true do
      let(:metadata_file) { File.join(fixture_path, 'importer', 'dataset', 'metadata.csv') }
      let(:files_directory) { File.join(fixture_path, 'importer', 'dataset', 'files') }
      let(:checksum_file_template) { File.join(fixture_path, 'importer', 'dataset', 'checksums.txt') }
      let(:checksum_dir) { Dir.mktmpdir }
      let(:checksum_file) { File.join(checksum_dir, 'checksums.txt') }
      let(:model) { 'Dataset' }
      let(:dataset_titles) { [ [ 'Test 1' ], [ 'Test 2' ], [ 'Test 3' ] ] }
      let(:ds1_checksums) { [ '4c4665b408134d8f6995d1640a7f2d4eeee5c010', 'ab84c8b1187123c4d627bea511714dd723b56dbe', '94631dfa806987fa6c01880d59303519f23c5609' ] }
      let(:ds2_checksums) { [ '37a0502601ed54f31d119d5355ade2c29ea530ea', '8376ba1d652cee933cc7cff95d8c049fb7a9a855' ] }
      let(:ds3_checksums) { [ '4c4665b408134d8f6995d1640a7f2d4eeee5c010' ] }
      subject { described_class.new(metadata_file, files_directory, model, checksum_file) }
      before do
        AdminSet.find_or_create_default_admin_set_id
        allow(CharacterizeJob).to receive(:perform_later)
        template = File.read(checksum_file_template)
        data = template.gsub('FIXTURE_PATH', fixture_path)
        File.open(checksum_file, 'w') do |f|
          f.write(data)
        end
      end
      after { FileUtils.rmdir(checksum_dir) }
      it 'imports the objects' do
        subject.import_all
        datasets = Dataset.all
        expect(datasets.size).to eq(3)
        expect(datasets.map(&:title)).to match_array(dataset_titles)
        ds1 = Dataset.where(title: 'Test 1').first
        ds2 = Dataset.where(title: 'Test 2').first
        ds3 = Dataset.where(title: 'Test 3').first
        expect(ds1.works).to match_array([ ds2, ds3 ])
        expect(ds2.in_works).to eq([ ds1 ])
        expect(ds3.in_works).to eq([ ds1 ])
        expect(ds1.visibility).to eq(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
        expect(ds2.visibility).to eq(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE)
        expect(ds3.visibility).to eq(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED)
        expect(ds1.file_sets.map(&:files).map(&:first).map(&:checksum).map(&:value)).to match_array(ds1_checksums)
        expect(ds2.file_sets.map(&:files).map(&:first).map(&:checksum).map(&:value)).to match_array(ds2_checksums)
        expect(ds3.file_sets.map(&:files).map(&:first).map(&:checksum).map(&:value)).to match_array(ds3_checksums)
      end
    end

  end
end
