require 'rails_helper'
require 'importer'

RSpec.describe Importer::CSVParser do
  let(:parser) { described_class.new(file) }
  let(:attributes) { parser.attributes }
  let(:file) { "#{fixture_path}/importer/metadata_samples/some_implicit_models.csv" }
  let(:first_record) { parser.first }

  context 'parsing metadata file' do
    it 'parses a record' do
      expect(first_record[:title]).to eq [ 'Test 1' ]
      expect(first_record[:file]).to eq [ 'data/data1.csv', 'data/data2.csv', 'docs/doc1.txt' ]
      expect(first_record[:contributor]).to eq [ 'Smith, Sue' ]
      expect(first_record[:license].first).to be_a String
      expect(first_record[:license]).to eq [ 'http://creativecommons.org/publicdomain/zero/1.0/' ]
      expect(first_record.keys).to match_array [ :type, :title, :contributor, :resource_type, :license, :file]
    end
  end

  describe 'validating CSV headers' do
    subject { parser.send(:validate_headers, headers) }

    context 'with valid headers' do
      let(:headers) { %w(id title parent_ark) }
      it { is_expected.to eq headers }
    end

    context 'with invalid headers' do
      let(:headers) { ['something bad', 'title'] }

      it 'raises an error' do
        expect { subject }.to raise_error 'Invalid headers: something bad'
      end
    end

    context 'with nil headers' do
      let(:headers) { ['title', nil] }
      it { is_expected.to eq headers }
    end

    # It doesn't expect a matching column for "resource_type"
    context 'with resource_type column' do
      let(:headers) { %w(resource_type title) }
      it { is_expected.to eq headers }
    end
  end

end
