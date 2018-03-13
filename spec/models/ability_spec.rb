require 'rails_helper'
require 'cancan/matchers'

RSpec.describe 'Ability', type: :model do

  let!(:user) { FactoryBot.build(:user) }

  subject { Ability.new(user) }

  describe 'batch imports' do
    describe 'user is a curator' do
      before do
        allow(User).to receive(:curators) { [ user.user_key ] }
      end
      it { is_expected.to be_able_to(:create, BatchImport) }
    end
    describe 'user is not a curator' do
      it { is_expected.to_not be_able_to(:create, BatchImport) }
    end
  end

end
