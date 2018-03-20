require 'rails_helper'

RSpec.describe DepositorAccessActor do

  describe '#create' do
    subject { described_class.new(env) }
    let(:user) { FactoryBot.build(:user) }
    let(:dataset) { Dataset.new(depositor: user.user_key) }
    let(:ability) { Ability.new(user) }
    let(:attributes) { { title: [ "Testing" ] } }
    let(:env) { Hyrax::Actors::Environment.new(dataset, ability, attributes) }
    let(:next_actor) { double }
    before do
      allow(subject).to receive(:next_actor) { next_actor }
      allow(next_actor).to receive(:create) { true }
    end
    describe 'depositor is a curator' do
      before do
        allow(User).to receive(:curators) { [ user.user_key ] }
      end
      it 'returns true' do
        expect(subject.create(env)).to be true
      end
    end
    describe 'depositor is not curator' do
      before do
        allow(User).to receive(:curators) { [ ] }
        allow(Hyrax::GrantReadToMembersJob).to receive(:perform_later)
        allow(Hyrax::RevokeEditFromMembersJob).to receive(:perform_later)
      end
      describe 'updated work is successfully saved' do
        before do
          allow(dataset).to receive(:save) { true }
        end
        it 'returns true' do
          expect(subject.create(env)).to be true
        end
      end
      describe 'updated work is not successfully saved' do
        before do
          allow(dataset).to receive(:save) { false }
        end
        it 'returns false' do
          expect(subject.create(env)).to be false
        end
      end
    end
  end

end
