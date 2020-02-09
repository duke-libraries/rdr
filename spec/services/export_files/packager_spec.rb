require 'rails_helper'

module ExportFiles
  RSpec.describe Packager do

    describe '#build!' do

      subject { Packager.new(package, top_work.id, ability: ability) }

      let(:user) { FactoryBot.create(:user) }
      let(:ability) { Ability.new(user) }
      let(:top_work) { FactoryBot.create(:dataset) }
      let(:nested_works) { FactoryBot.create_list(:dataset_with_files, 2) }
      let(:file_names) { [ [ 'data.csv', 'data2.csv' ], [ 'doc1.txt', 'doc2.txt' ] ] }
      let(:basename) { 'Export_Test' }
      let(:package) { Package.new(top_work.id, ability: ability, basename: basename) }
      let(:export_files_dir) { Dir.mktmpdir }
      let(:storage_subpath) { '20180219-141303-613' }
      let(:base_path) { File.join(export_files_dir, storage_subpath, basename) }
      let(:files_path) { File.join(base_path, 'data', 'files') }

      before do
        allow(Rdr).to receive(:export_files_store) { export_files_dir }
        allow(Storage).to receive(:generate_subpath) { storage_subpath }
        nested_works.each { |wrk| top_work.ordered_members << wrk }
        allow(ability).to receive(:can?) { true }
        file_names.each_with_index do |val, index|
          val.each_with_index do |v , idx|
            Hydra::Works::UploadFileToFileSet.call(nested_works[index].file_sets[idx], File.open(File.join(fixture_path, v)))
          end
        end
        top_work.save!
      end

      after do
        FileUtils.rm_r(export_files_dir)
      end

      it 'builds the appropriate bag data' do
        subject.build!
        expect(Dir.entries(base_path)).to include('README.txt')
        expect(Dir.entries(File.join(files_path, '0001_Test_title'))).to contain_exactly( *file_names[0], '.', '..' )
        expect(Dir.entries(File.join(files_path, '0002_Test_title'))).to contain_exactly( *file_names[1], '.', '..' )
      end
    end

  end
end
