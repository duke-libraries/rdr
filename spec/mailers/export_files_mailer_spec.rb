require 'rails_helper'

RSpec.describe ExportFilesMailer do

  let(:user) { FactoryBot.create(:user) }
  let(:repo_id) { "testzg88m" }

  describe "notify_success" do
    before do
      allow(ActiveFedora::Base).to receive(:find).with(repo_id) { double(id: repo_id) }
      allow_any_instance_of(WorkFilesScanner).to receive(:scan) {}
    end
    it "works" do
      export = ExportFiles::Package.new(repo_id)
      described_class.notify_success(export, user.email).deliver_now!
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to match /COMPLETED/
    end
  end

end
