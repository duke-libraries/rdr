require 'rails_helper'

RSpec.describe Collection do
  describe 'ark' do
    let(:ark) { 'ark:/99999/fk4n59w04m' }
    it 'has an ark property' do
      subject.ark = ark
      expect(subject.ark).to eq(ark)
    end
  end

  describe "#mint_ark_for_collection" do
    subject { FactoryBot.build(:collection_lw) }
    it 'enqueues a job to activate the ARK' do
      expect(MintPublishArkJob).to receive(:perform_later)
      subject.save!
    end
  end
end
