require 'rails_helper'

module ExportFiles
  RSpec.describe MetadataReport do

    describe '#generate' do
      let(:dataset) { FactoryBot.create(:dataset_with_files, creator: [ 'a', 'b' ], available: [ '2019-12-04' ]) }
      let(:user) { FactoryBot.create(:user) }
      let(:ability) { Ability.new(user) }
      let(:basename) { 'test_export' }
      let(:package) { Package.new(dataset.id, ability: ability, basename: basename) }
      let(:file_count) { 4 }
      let(:file_size) { 27309 }
      let(:human_file_size) { '26.7 KB' }
      let(:timestamp_regex) do
        '[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]) (2[0-3]|[01][0-9]):[0-5][0-9]:[0-5][0-9] [+-]\d{4}'
      end
      let(:policy) do
        File.read(File.join(Rails.root, 'app', 'services', 'export_files', 'acceptable_use_policy.txt'))
      end

      subject { described_class.new(package) }

      before do
        allow(subject).to receive(:file_size_and_count).and_return([ file_size.to_s, file_count.to_s ])
      end

      it 'produces the appropriate report' do
        rpt = subject.generate
        # has a first line with the dataset title
        expect(rpt).to start_with(I18n.t('rdr.batch_export.metadata_report.first_line', title: dataset.title.first))
        # contains the creators
        expect(rpt).to match(/.*#{I18n.t('rdr.show.fields.creator')}: [a; b|b; a].*/)
        # publication date shows date only
        expect(rpt).to match(/.*#{I18n.t('rdr.show.fields.available')}: \d\d\d\d-\d\d-\d\d$/)
        # contains file count
        expect(rpt).to include("#{I18n.t('rdr.batch_export.metadata_report.file_count')}: #{file_count}")
        # contains file size
        expect(rpt).to include("#{I18n.t('rdr.batch_export.metadata_report.file_size')}: #{human_file_size}")
        # contains a timestamp for the export
        expect(rpt).to match(/.*#{I18n.t('rdr.batch_export.metadata_report.export_timestamp')}: #{timestamp_regex}.*/)
        # contains the text of acceptable use policy
        expect(rpt).to include(policy)
      end
    end

    describe '#file_size_and_count' do
      let(:package) { double('Package') }
      let(:file_count) { 4 }
      let(:file_size) { 27309 }
      before do
        allow(package).to receive_message_chain(:bag, :payload_oxum).and_return("#{file_size}.#{file_count}")
      end
      subject { described_class.new(package) }
      it 'returns the correct file size and count' do
        expect(subject.file_size_and_count).to eq([ file_size.to_s, file_count.to_s ])
      end
    end

  end
end
