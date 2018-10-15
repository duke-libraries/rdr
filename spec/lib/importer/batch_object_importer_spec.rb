require 'rails_helper'
require 'importer'

# Initialized with model (string), attributes (hash<string: string>), files_directory
# Instantiates and runs object factory
module Importer
  RSpec.describe BatchObjectImporter do

    subject { described_class.new(model, attributes, files_directory) }

    let(:model) { 'Dataset' }
    let(:attributes) do {
                          identifier: ['123'],
                          title: ['Test dataset'],
                          read_groups: ['public'],
                          edit_users: ['bob'],
                        }
    end
    let(:files_directory) { '/tmp' }

    it 'instantiates and runs the appropriate object factory' do
      expect(Importer::Factory::DatasetFactory).to receive(:new).with(attributes, files_directory).and_call_original
      expect_any_instance_of(Importer::Factory::DatasetFactory).to receive(:run)
      subject.call
    end

  end
end
