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

end
