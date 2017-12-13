require 'rails_helper'

RSpec.describe User do

  subject { described_class.new(uid: "0000000", email: "duke@example.com") }

  its(:to_s) { is_expected.to eq "0000000" }

end
