require 'rails_helper'

RSpec.describe IngestJob do

  describe 'finished' do
      let(:wrapper) { double('JobIOWrapper') }
    before do
      allow(wrapper).to receive(:ingest_file)
      allow(ActiveSupport::Notifications).to receive(:instrument)
    end
    it 'emits a notification' do
      expect(ActiveSupport::Notifications).to receive(:instrument).with(Rdr::Notifications::FILE_INGEST_FINISHED,
                                                                        wrapper: wrapper)
      subject.perform(wrapper)
    end
  end

end
