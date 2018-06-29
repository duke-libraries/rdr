require 'rails_helper'

RSpec.describe RdrSubmissionHelper, type: :helper do

  describe '#include_submission_entry?' do
    let(:authors_value) { 'Spade, Sam; Fletcher, Jessica' }
    let(:submission) { Submission.new(creator: authors_value) }
    describe 'has value' do
      it 'returns true' do
        expect(helper.include_submission_entry?(submission, :creator)).to be true
      end
    end
    describe 'does not have value' do
      it 'returns true' do
        expect(helper.include_submission_entry?(submission, :contributor)).to be false
      end
    end
  end

  describe '#submission_entry' do
    let(:authors_label) { 'Authors' }
    let(:authors_value) { 'Spade, Sam; Fletcher, Jessica' }
    let(:submission) { Submission.new(creator: authors_value) }
    before do
      allow(helper).to receive(:t).with('rdr.submissions.email.label.creator') { 'Authors' }
    end
    it 'returns the label and value' do
      expect(helper.submission_entry(submission, :creator)).to eq("#{authors_label}: #{authors_value}")
    end
  end

  describe '#submission_folder_url' do
    let(:folder_id) { '1234' }
    before do
      allow(Rdr).to receive(:box_base_url_rdr_submissions) { 'http://testbox.example.org' }
    end
    it 'returns the folder url' do
      expect(helper.submission_folder_url(folder_id)).to eq("#{Rdr.box_base_url_rdr_submissions}/folder/#{folder_id}")
    end
  end

end
