require 'rails_helper'

# Copied portions of test suite relevant to monkey-patched method (#fixity_check_file) from Hyrax project
# and added test to exercise the patch.
RSpec.describe Hyrax::FileSetFixityCheckService do
  let(:f)                 { create(:file_set, content: File.open(fixture_path + '/world.png')) }
  let(:service_by_object) { described_class.new(f) }
  let(:service_by_id)     { described_class.new(f.id) }

  describe "async_jobs: false" do
    let(:service_by_object) { described_class.new(f, async_jobs: false) }
    let(:service_by_id)     { described_class.new(f.id, async_jobs: false) }

    describe '#fixity_check_file' do
      subject { service_by_object.send(:fixity_check_file, f.original_file) }

      specify 'returns a single result' do
        expect(subject.length).to eq(1)
      end

      # Added this test to exercise the monkey patch in the #fixity_check_file method.
      describe 'non-versioned file with latest version only' do
        let(:service_by_object) { described_class.new(f, async_jobs: false, latest_version_only: true) }

        before do
          allow(f.original_file).to receive(:has_versions?) { false }
        end

        subject { service_by_object.send(:fixity_check_file, f.original_file) }

        specify 'returns a single result' do
          expect(subject.length).to eq(1)
        end
      end

    end

  end

end
