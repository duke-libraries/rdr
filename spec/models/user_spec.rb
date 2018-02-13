require 'rails_helper'

RSpec.describe User do

  subject { described_class.new(uid: "0000000", email: "duke@example.com") }

  its(:to_s) { is_expected.to eq "0000000" }

  describe "overridden system user creation" do
    it "successfully creates system users" do
      expect{ User.audit_user }.to change{User.count}.by(1)
      expect{ User.batch_user }.to change{User.count}.by(1)
    end
  end

 describe "#add_curators_as_proxies" do

    let(:curatorA) { FactoryBot.create(:user) }
    let(:curatorB) { FactoryBot.create(:user) }

    before do
      # stub group service implementation to return curator group members
      allow(RoleMapper).to receive(:whois).with(User::CURATOR_GROUP).and_return([ curatorA.uid, curatorB.uid ])
    end

    it "adds all curators as proxy depositors for new user" do
      owner_user = FactoryBot.create(:user, email: "user@example.com")
      expect(owner_user.can_receive_deposits_from).to match_array([curatorA, curatorB])
    end

    it "does not add curators as proxy depositors for new system users" do
      expect(User.audit_user.can_receive_deposits_from).to be_empty
      expect(User.batch_user.can_receive_deposits_from).to be_empty
     end
  end
end
