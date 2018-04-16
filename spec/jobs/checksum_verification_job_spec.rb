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

  describe '#user_to_notify' do
    let(:user) { FactoryBot.create(:user) }
    let(:file_set_id) { '1g05fb60f' }
    let(:file_set) { double('FileSet') }
    let(:wrapper) { double('JobIOWrapper', file_set_id: file_set_id) }
    before do
      allow(FileSet).to receive(:find).with(file_set_id) { file_set }
      allow(file_set).to receive(:parent) { work }
    end
    describe 'proxy depositor on parent work' do
      let(:work) { double('Dataset', proxy_depositor: user.user_key) }
      it 'is the proxy depositor' do
        expect(subject.user_to_notify(wrapper)).to eq(user)
      end
    end
    describe 'depositor on parent work (but no proxy depositor)' do
      let(:work) { double('Dataset', depositor: user.user_key, proxy_depositor: nil) }
      it 'is the depositor' do
        expect(subject.user_to_notify(wrapper)).to eq(user)
      end
    end
    # edge case that may not be possible in reality
    describe 'neither depositor nor proxy depositor on parent work' do
      let(:wrapper) { double('JobIOWrapper', file_set_id: file_set_id, user: user) }
      let(:work) { double('Dataset', depositor: nil, proxy_depositor: nil) }
      it 'is the user from the wrapper' do
        expect(subject.user_to_notify(wrapper)).to eq(user)
      end
    end

  end
end
