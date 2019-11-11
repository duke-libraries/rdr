require 'rails_helper'
require 'support/ezid_mock_identifier'

RSpec.describe 'actor stack processing' do

  describe '#destroy', integration: true do
    let(:dataset) { FactoryBot.create(:dataset) }
    let(:user) { FactoryBot.create(:user) }
    let(:ability) { Ability.new(user) }
    let(:env) { Hyrax::Actors::Environment.new(dataset, ability, nil) }

    subject { Hyrax::CurationConcern.actor }

    describe 'ARK management' do
      around(:example) do |example|
        ark_identifier_class = Ark.identifier_class
        Ark.identifier_class = Ezid::MockIdentifier
        example.run
        Ark.identifier_class = ark_identifier_class
      end
      let!(:ark) { Ark.new(dataset, Ark.mint) }
      before do
        dataset.update_attributes(ark: ark.id)
        allow(Ark).to receive(:new).with(nil, ark.id) { ark }
      end
      describe 'work has public ARK' do
        before do
          allow(ark.identifier).to receive(:public?) { true }
        end
        it 'deactivates the ARK' do
          # ensure that we didn't mess up existing #destroy processing
          expect_any_instance_of(Hyrax::Actors::BaseActor).to receive(:destroy).with(env).and_call_original
          expect(ark).to receive(:deactivate!)
          subject.destroy(env)
        end
      end
      describe 'work has reserved ARK' do
        before do
          allow(ark.identifier).to receive(:reserved?) { true }
        end
        it 'deletes the ARK' do
          # ensure that we didn't mess up existing #destroy processing
          expect_any_instance_of(Hyrax::Actors::BaseActor).to receive(:destroy).with(env).and_call_original
          expect(ark).to receive(:delete!)
          subject.destroy(env)
        end
      end
    end
  end

end
