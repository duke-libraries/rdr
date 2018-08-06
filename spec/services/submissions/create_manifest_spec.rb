require 'rails_helper'
require 'csv'

module Submissions
  RSpec.describe CreateManifest do

    describe '#call' do
      subject { described_class.new(submission) }

      let(:manifest_path) { subject.call }
      let(:ark) { "ark:/99999/fk49s2zx5j" }
      let(:ark_identifier) { Ezid::Identifier.new(ark) }
      let(:title) { "Title of Work" }
      let(:first_creator) { "Author1Last, Author1First" }
      let(:second_creator) { "Author2Last, Author2First" }
      let(:affiliation) { "institutionXYZ" }
      let(:first_subject) { "stuff" }
      let(:second_subject) { "more stuff" }
      let(:based_near) { "London, England" }
      let(:doi) { "123456789" }

      before do
        allow(Ark).to receive(:mint) { ark_identifier }
      end

      after do
        FileUtils.rm_rf(File.dirname(manifest_path))
      end

      context 'creates a manifest file using CC0 license' do
        let(:license) { CreateManifest::CC0_LICENSE }
        let(:submission) { Submission.new({ title: title,
                                            creator: "#{first_creator}; #{second_creator}",
                                            affiliation: affiliation,
                                            subject: "#{first_subject}; #{second_subject}",
                                            based_near: based_near,
                                            doi: doi,
                                            using_cc0: Submission::USE_CC0
                                          }) }
        let(:header_row) { [ "ark", "title", "creator", "creator", "affiliation", "subject", "subject", "based_near",
                             "doi", "license" ] }
        let(:data_row) { [ ark, title, first_creator, second_creator, affiliation, first_subject, second_subject,
                           based_near, doi, license ] }

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
        let(:license) { "https://opensource.org/licenses/GPL-3.0" }
        let(:submission) { Submission.new({ title: title,
                                            creator: "#{first_creator}; #{second_creator}",
                                            affiliation: affiliation,
                                            subject: "#{first_subject}; #{second_subject}",
                                            based_near: based_near,
                                            doi: doi,
                                            using_cc0: Submission::NOT_USE_CC0,
                                            license: license
                                          }) }
        let(:header_row) { [ "ark", "title", "creator", "creator", "affiliation", "subject", "subject", "based_near",
                             "doi", "license" ] }
        let(:data_row) { [ ark, title, first_creator, second_creator, affiliation, first_subject, second_subject,
                           based_near, doi, license ] }

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
