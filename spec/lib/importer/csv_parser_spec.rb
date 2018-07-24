require 'rails_helper'
require 'importer'

RSpec.describe Importer::CSVParser do
  let(:file) { "#{fixture_path}/importer/manifest_samples/sample.csv" }
  let(:first_record) { subject.first }

  subject { described_class.new(file) }

  context 'parsing metadata file' do
    it 'parses a record' do
      expect(first_record[:title]).to eq [ 'Test 1' ]
      expect(first_record[:file]).to eq [ 'data/data1.csv', 'data/data2.csv', 'docs/doc1.txt' ]
      expect(first_record[:contributor]).to eq [ 'Smith, Sue', 'Jones, Bill', 'Allen, Jane' ]
      expect(first_record[:license].first).to be_a String
      expect(first_record[:license]).to eq [ 'http://creativecommons.org/publicdomain/zero/1.0/' ]
      expect(first_record[:visibility]).to eq [ 'open' ]
      expect(first_record.keys).to match_array [ :visibility, :title, :contributor, :resource_type, :license, :file ]
    end
  end

  describe '#headers' do
    specify { expect(subject.headers).to eq(%w(visibility title contributor resource_type license file file file)) }
  end

end
