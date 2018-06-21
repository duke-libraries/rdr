require 'rails_helper'

RSpec.describe SubmissionsMailer, type: :mailer do

  let(:submitter) { FactoryBot.create(:user, display_name: 'Rey Researcher') }
  let(:submitter_netid) { submitter.user_key.split('@').first }
  let(:submission) { Submission.new(submission_attrs) }

  before do
    allow(Rdr).to receive(:curation_group_email) { 'curators@example.org' }
  end

  describe 'notify acreened out' do
    let(:submission_attrs) { { submitter: submitter, screening_pii: 'true' } }

    it 'sends an appropriate email' do
      described_class.notify_screened_out(submission).deliver_now!
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to match_array([ Rdr.curation_group_email ])
      expect(mail.from).to match_array([ Rdr.curation_group_email ])
      expect(mail.subject).to eq(I18n.t('rdr.submissions.email.screened_out.subject'))
      expect(mail.body.encoded).to match("Submitter: #{submitter.display_name}")
      expect(mail.body.encoded).to match("Net ID: #{submitter_netid}")
      expect(mail.body.encoded).to match("#{I18n.t('rdr.submissions.label.screening_pii')}: #{submission_attrs[:screening_pii]}")
      expect(mail.body.encoded).to_not match("#{I18n.t('rdr.submissions.label.screening_funding')}:")
    end
  end

  describe 'notify success' do
    let(:submission_attrs) { { submitter: submitter, title: 'My Research Data Project', screening_pii: 'false',
                               authors: 'Spade, Sam; Tracy, Dick; Fletcher, Jessica' } }
    let(:submission_folder_id) { '1234567890' }
    let(:submission_folder_name) { "#{submitter_netid}_201804211423" }
    let(:submission_folder) { double('BoxrMash', etag: '0',  id: submission_folder_id, name: submission_folder_name,
                                     type: 'folder') }
    let(:submission_folder_url) { "#{Rdr.box_base_url_rdr_submissions}/folder/#{submission_folder_id}"}
    let(:submission_instructions) { 'instructions to the researcher' }

    before do
      allow(Rdr).to receive(:box_base_url_rdr_submissions) { 'https://testbox.example.org' }
      allow(Rdr).to receive(:submission_instructions) { submission_instructions }
    end

    it 'sends an appropriate email' do
      described_class.notify_success(submission, submission_folder).deliver_now!
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to match_array([ submitter.email, Rdr.curation_group_email ])
      expect(mail.from).to match_array([ Rdr.curation_group_email ])
      expect(mail.subject).to eq(I18n.t('rdr.submissions.email.success.subject'))
      expect(mail.body.encoded).to match("Submitter: #{submitter.display_name}")
      expect(mail.body.encoded).to match("Net ID: #{submitter_netid}")
      expect(mail.body.encoded).to match("Submission Folder Name: #{submission_folder.name}")
      expect(mail.body.encoded).to match("Submission Folder URL: #{submission_folder_url}")
      expect(mail.body.encoded).to match(submission_instructions)
      expect(mail.body.encoded).to match("#{I18n.t('rdr.submissions.label.screening_pii')}: #{submission_attrs[:screening_pii]}")
      expect(mail.body.encoded).to match("#{I18n.t('rdr.submissions.label.title')}: #{submission_attrs[:title]}")
      expect(mail.body.encoded).to match("#{I18n.t('rdr.submissions.label.authors')}: #{submission_attrs[:authors]}")
      expect(mail.body.encoded).to_not match("#{I18n.t('rdr.submissions.label.contributors')}:")
    end
  end

end
