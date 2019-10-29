require 'rails_helper'

RSpec.describe ExportFilesJob do

  describe 'called with user ID' do
    let(:user) { FactoryBot.create(:user) }
    describe 'package' do
      before do
        allow(ExportFilesMailer).to receive_message_chain(:notify_success, :deliver_now)
      end
      it "calls ExportFiles::Package with that user's ability" do
        expect(ExportFiles::Package).to receive(:call).with(String, ability: have_attributes(current_user: user),
                                                            basename: String)
        subject.perform('foo', user.id, nil, 'bar')
      end
    end
    describe 'mailer' do
      let(:archive) { double('ExportFiles::Archive') }
      let(:mail) { double(deliver_now: nil) }
      before do
        allow(ExportFiles::Package).to receive(:call).with(String, ability: Ability, basename: String) { archive }
      end
      it 'calls ExportFilesMailer with that user' do
        expect(ExportFilesMailer).to receive(:notify_success).with(archive, user).and_return(mail)
        subject.perform('foo', user.id, nil, 'bar')
      end
    end
  end

  describe 'called with email address' do
    let(:email) { 'foo@site.com' }
    describe 'package' do
      before do
        allow(ExportFilesMailer).to receive_message_chain(:notify_success, :deliver_now)
      end
      it "calls ExportFiles::Package with that ability of unpersisted user with that email address" do
        expect(ExportFiles::Package).to receive(:call)
                                            .with(String,
                                                  ability: have_attributes(current_user: have_attributes(id: nil,
                                                                                                         email: email)),
                                                  basename: String)
        subject.perform('foo', nil, email, 'bar')
      end
    end
    describe 'mailer' do
      let(:archive) { double('ExportFiles::Archive') }
      let(:mail) { double(deliver_now: nil) }
      before do
        allow(ExportFiles::Package).to receive(:call).with(String, ability: Ability, basename: String) { archive }
      end
      it 'calls ExportFilesMailer with unpersisted user with that email address' do
        expect(ExportFilesMailer).to receive(:notify_success)
                                         .with(archive,
                                               have_attributes(id: nil, email: email))
                                         .and_return(mail)
        subject.perform('foo', nil, email, 'bar')
      end
    end
  end

  describe 'called with user ID and email address' do
    it 'raises an ArgumentError' do
      expect{ subject.perform('foo', 1, 'foo@site.com', 'bar') }
                                .to raise_error(ArgumentError, I18n.t('rdr.export_files.job_user_id_and_email_error'))
    end
  end

end
