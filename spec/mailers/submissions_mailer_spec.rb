require 'rails_helper'

RSpec.describe SubmissionsMailer, type: :mailer do

  let(:submitter) { FactoryBot.create(:user, uid: 'user3@duke.edu', display_name: 'Rey Researcher') }
  let(:submission) { Submission.new(submission_attrs) }

  before do
    allow(Rdr).to receive(:curation_group_email) { 'curators@example.org' }
  end

  describe 'notify error' do
    let(:submission_attrs) { { submitter: submitter, deposit_agreement: Submission::AGREE } }
    let(:errors) { ActiveModel::Errors.new(submission) }
    before do
      errors.add(:title, :blank, message: "can't be blank")
      allow(submission).to receive(:errors)  { errors }
    end
    it 'sends an appropriate email' do
      described_class.notify_error(submission).deliver_now!
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to match_array([ Rdr.curation_group_email ])
      expect(mail.from).to match_array([ Rdr.curation_group_email ])
      expect(mail.subject).to eq(I18n.t('rdr.submissions.email.error.subject'))
      expect(mail.body.encoded).to match("Submitter: #{submitter.display_name}")
      expect(mail.body.encoded).to match("Net ID: #{submitter.netid}")
      expect(mail.body.encoded).to match(I18n.t('rdr.submissions.email.error.message'))
      errors.full_messages.each do |msg|
        expect(mail.body.encoded).to match(msg)
      end
      expect(mail.body.encoded).to match("#{I18n.t('rdr.submissions.email.label.deposit_agreement')}: #{submission_attrs[:deposit_agreement]}")
    end
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
      expect(mail.body.encoded).to match("Net ID: #{submitter.netid}")
      expect(mail.body.encoded).to match("#{I18n.t('rdr.submissions.email.label.screening_pii')}: #{submission_attrs[:screening_pii]}")
      expect(mail.body.encoded).to_not match("#{I18n.t('rdr.submissions.email.label.screening_funding')}:")
    end
  end

  describe 'notify followup' do
    let(:submission_attrs) { { submitter: submitter, followup: 'true', more_information: 'here is some more information for you' } }

    it 'sends an appropriate email' do
      described_class.notify_followup(submission).deliver_now!
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to match_array([ Rdr.curation_group_email ])
      expect(mail.from).to match_array([ Rdr.curation_group_email ])
      expect(mail.subject).to eq(I18n.t('rdr.followup.email.subject'))
      expect(mail.body.encoded).to match("Submitter: #{submitter.display_name}")
      expect(mail.body.encoded).to match("Net ID: #{submitter.netid}")
      expect(mail.body.encoded).to match("#{submission_attrs[:more_information]}")
    end
  end

  describe 'notify success' do
    let(:submission_attrs) { { submitter: submitter, title: 'My Research Data Project', screening_pii: 'false',
                               creator: 'Spade, Sam; Tracy, Dick; Fletcher, Jessica' } }
    let(:submission_folder_id) { '1234567890' }
    let(:submission_folder_name) { "#{submitter.netid}_201804211423" }
    let(:submission_folder) { double('BoxrMash', etag: '0',  id: submission_folder_id, name: submission_folder_name,
                                     type: 'folder') }
    let(:submission_folder_url) { "#{Rdr.box_base_url_rdr_submissions}/folder/#{submission_folder_id}"}

    before do
      allow(Rdr).to receive(:box_base_url_rdr_submissions) { 'https://testbox.example.org' }
    end

    it 'sends an appropriate email' do
      described_class.notify_success(submission, submission_folder).deliver_now!
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to match_array([ submitter.email, Rdr.curation_group_email ])
      expect(mail.from).to match_array([ Rdr.curation_group_email ])
      expect(mail.subject).to eq(I18n.t('rdr.submissions.email.success.subject'))
      expect(mail.body.encoded).to match("Submitter: #{submitter.display_name}")
      expect(mail.body.encoded).to match("Net ID: #{submitter.netid}")
      expect(mail.body.encoded).to match("Submission Folder Name: #{submission_folder.name}")
      expect(mail.body.encoded).to match("Submission Folder URL: #{submission_folder_url}")
      expect(mail.body.encoded).to match(I18n.t('rdr.submissions.email.success.text', email: Rdr.curation_group_email))
      expect(mail.body.encoded).to match("#{I18n.t('rdr.submissions.email.label.screening_pii')}: #{submission_attrs[:screening_pii]}")
      expect(mail.body.encoded).to match("#{I18n.t('rdr.submissions.email.label.title')}: #{submission_attrs[:title]}")
      expect(mail.body.encoded).to match("#{I18n.t('rdr.submissions.email.label.creator')}: #{submission_attrs[:creator]}")
      expect(mail.body.encoded).to_not match("#{I18n.t('rdr.submissions.email.label.contributor')}:")
    end
  end

end
