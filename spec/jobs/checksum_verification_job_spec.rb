require 'rails_helper'

RSpec.describe ChecksumVerificationJob do

  describe '#perform' do
    let(:wrapper) { double('JobIOWrapper') }
    it 'uses ChecksumVerificationService to verify checksums' do
      expect_any_instance_of(ChecksumVerificationService).to receive(:verify_checksum)
      subject.perform(wrapper)
    end
  end

  describe 'checksum verification error' do
    let(:user) { FactoryBot.create(:user) }
    let(:file_set_id) { '1g05fb60f' }
    let(:file_set) { double('FileSet') }
    let(:work) { Dataset.new }
    let(:wrapper) { double('JobIOWrapper', file_set_id: file_set_id, user: user) }
    before do
      allow_any_instance_of(ChecksumVerificationService).to receive(:verify_checksum).and_raise(Rdr::ChecksumInvalid)
      allow(FileSet).to receive(:find).with(file_set_id) { file_set }
      allow(file_set).to receive(:parent) { work }
    end
    it 'sends an email' do
      begin
        expect{ subject.perform(wrapper) }.to change{ActionMailer::Base.deliveries.count}.by(1)
      rescue Rdr::ChecksumInvalid
      end
    end
  end

end
