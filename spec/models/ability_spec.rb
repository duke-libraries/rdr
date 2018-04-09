require 'rails_helper'
require 'cancan/matchers'

RSpec.describe 'Ability', type: :model do

  let!(:user) { FactoryBot.build(:user) }

  subject { Ability.new(user) }

  describe 'assign_register_doi' do
    describe 'user is a curator' do
      before do
        allow(user).to receive(:curator?) { true }
      end
      it { is_expected.to be_able_to(:assign_register_doi, Dataset) }
    end
    describe 'user is not a curator' do
      it { is_expected.to_not be_able_to(:assign_register_doi, Dataset) }
    end
  end

  describe 'batch imports' do

    describe 'user is a curator' do

      before do
        allow(user).to receive(:curator?) { true }
      end

      it { is_expected.to be_able_to(:create, BatchImport) }

    end

    describe 'user is not a curator' do
      it { is_expected.to_not be_able_to(:create, BatchImport) }
    end

  end

  describe 'create works' do
    describe 'user is a curator' do
      before do
        allow(user).to receive(:curator?) { true }
      end
      it { is_expected.to be_able_to(:create, Dataset) }
    end

    describe 'user is not a curator' do
      it { is_expected.to_not be_able_to(:create, Dataset) }
    end
  end

end
