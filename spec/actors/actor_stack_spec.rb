require 'rails_helper'
require 'ezid/test_helper'

RSpec.describe 'actor stack processing' do

  describe '#destroy', integration: true do
    let(:dataset) { FactoryBot.create(:dataset) }
    let(:user) { FactoryBot.create(:user) }
    let(:ability) { Ability.new(user) }
    let(:env) { Hyrax::Actors::Environment.new(dataset, ability, nil) }

    subject { Hyrax::CurationConcern.actor }

    before { ezid_test_mode! }

    describe 'ARK management' do
      let!(:ark) { Ark.identifier_class.mint }
      before do
        dataset.update_attributes(ark: ark.id)
      end
      describe 'work has public ARK' do
        before do
          ark.public!
          ark.save
        end
        it 'marks the ARK as unavailable' do
          # ensure that we didn't mess up existing #destroy processing
          expect_any_instance_of(Hyrax::Actors::BaseActor).to receive(:destroy).with(env).and_call_original
          subject.destroy(env)
          expect(ark.status).to match(/#{Ezid::Status::UNAVAILABLE} | Rdr.deaccession_reason/)
        end
      end
      describe 'work has reserved ARK' do
        it 'deletes the ARK' do
          # ensure that we didn't mess up existing #destroy processing
          expect_any_instance_of(Hyrax::Actors::BaseActor).to receive(:destroy).with(env).and_call_original
          subject.destroy(env)
          expect{ Ezid::Identifier.find(ark.id) }.to raise_error(Ezid::IdentifierNotFoundError)
        end
      end
    end
  end

end
