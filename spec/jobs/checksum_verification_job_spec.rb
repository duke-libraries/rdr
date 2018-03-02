require 'rails_helper'

RSpec.describe ChecksumVerificationJob do

  describe '#perform' do
    let(:wrapper) { double('JobIOWrapper') }
    it 'uses ChecksumVerificationService to verify checksums' do
      expect_any_instance_of(ChecksumVerificationService).to receive(:verify_checksum)
      subject.perform(wrapper)
    end
  end

end
