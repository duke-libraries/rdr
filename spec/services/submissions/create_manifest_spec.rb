require 'rails_helper'
require 'csv'

module Submissions
  RSpec.describe CreateManifest do

    describe '#call' do
      subject { described_class.new(submission) }

      let(:manifest_path) { subject.call }

      after do
        FileUtils.rm_rf(File.dirname(manifest_path))
      end

      context 'creates a manifest file using CC0 license' do
        let(:submission) { Submission.new(
            {title: "Title of Work_A",
             creator: "Author1Last_A, Author1First_A; Author2Last_A, Author2First_A",
             affiliation: "institutionXYZ_A",
             based_near: "London, England_A",
             doi: "123456789_A",
             using_cc0: Submission::USE_CC0
            }) }
        let(:header_row) { ["title", "creator", "creator", "affiliation", "based_near", "doi", "license"] }
        let(:data_row) { ["Title of Work_A", "Author1Last_A, Author1First_A", "Author2Last_A, Author2First_A", "institutionXYZ_A",
                          "London, England_A","123456789_A", CreateManifest::CC0_LICENSE ] }

        it 'includes the CC0 license' do
          arr = []
          CSV.foreach(manifest_path) do |row|
            arr.push(row)
          end
          expect(arr[1]).to eq data_row
          expect(arr[0]).to eq header_row
        end
      end

      context 'creates a manifest file not using CC0 license' do
        let(:submission) { Submission.new(
            {title: "Title of Work_B",
             creator: "Author1Last_B, Author1First_B; Author2Last_B, Author2First_B",
             affiliation: "institutionXYZ_B ",
             based_near: " London, England_B",
             doi: "123456789_B",
             using_cc0: Submission::NOT_USE_CC0,
             license: "https://opensource.org/licenses/GPL-3.0"
            }) }
        let(:header_row) { ["title", "creator", "creator", "affiliation", "based_near", "doi", "license"] }
        let(:data_row) { ["Title of Work_B", "Author1Last_B, Author1First_B", "Author2Last_B, Author2First_B", "institutionXYZ_B",
                          "London, England_B","123456789_B", "https://opensource.org/licenses/GPL-3.0" ] }

        it 'includes the non-CC0 user-provided license' do
          arr = []
          CSV.foreach(manifest_path) do |row|
            arr.push(row)
          end
          expect(arr[1]).to eq data_row
          expect(arr[0]).to eq header_row
        end
      end
    end
  end
end
