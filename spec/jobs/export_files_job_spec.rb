require 'rails_helper'

RSpec.describe ExportFilesJob do

  describe 'called with user ID only' do
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
        expect(ExportFilesMailer).to receive(:notify_success).with(archive, user.email).and_return(mail)
        subject.perform('foo', user.id, nil, 'bar')
      end
    end
  end

  describe 'called with email address only' do
    let(:email) { 'foo@site.com' }
    describe 'package' do
      before do
        allow(ExportFilesMailer).to receive_message_chain(:notify_success, :deliver_now)
      end
      it "calls ExportFiles::Package with that ability of unpersisted user" do
        expect(ExportFiles::Package).to receive(:call)
                                            .with(String,
                                                  ability: have_attributes(current_user: have_attributes(id: nil)),
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
                                         .with(archive, email)
                                         .and_return(mail)
        subject.perform('foo', nil, email, 'bar')
      end
    end
  end

  describe 'called with user ID and email address' do
    let(:user) { FactoryBot.create(:user) }
    let(:email) { 'foo@site.com' }
    describe 'package' do
      before do
        allow(ExportFilesMailer).to receive_message_chain(:notify_success, :deliver_now)
      end
      it "calls ExportFiles::Package with the authenticated user's ability" do
        expect(ExportFiles::Package).to receive(:call).with(String, ability: have_attributes(current_user: user),
                                                            basename: String)
        subject.perform('foo', user.id, email, 'bar')
      end
    end
    describe 'mailer' do
      let(:archive) { double('ExportFiles::Archive') }
      let(:mail) { double(deliver_now: nil) }
      before do
        allow(ExportFiles::Package).to receive(:call).with(String, ability: Ability, basename: String) { archive }
      end
      it 'calls ExportFilesMailer with unpersisted user with the provided email address' do
        expect(ExportFilesMailer).to receive(:notify_success)
                                         .with(archive, email)
                                         .and_return(mail)
        subject.perform('foo', user.id, email, 'bar')
      end
    end

  end

end
