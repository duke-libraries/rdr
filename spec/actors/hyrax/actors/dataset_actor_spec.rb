# Generated via
#  `rails generate hyrax:work Dataset`
require 'rails_helper'
require 'ezid-client'

RSpec.describe Hyrax::Actors::DatasetActor do

  describe '#destroy' do
    let(:user) { FactoryBot.build(:user) }
    let(:ability) { Ability.new(user) }
    let(:dataset) { FactoryBot.create(:dataset) }
    let(:env) { Hyrax::Actors::Environment.new(dataset, ability, nil) }
    let(:ark) { 'foo' }
    let(:id) { Ark.identifier_class.new(dataset.ark) }

    before do
      allow_any_instance_of(Ark).to receive(:identifier) { id }
      allow(id).to receive(:save) { nil }
    end

    subject { described_class.new(nil) }

    describe 'work has an ARK' do
      before { dataset.update_attributes(ark: ark) }
      it 'enqueues a job to deactivate the ARK' do
        expect(DeactivateArkJob).to receive(:perform_later).with(ark)
        subject.destroy(env)
      end
    end

    describe 'work does not have an ARK' do
      it 'does not enqueue a job to deactivate the ARK' do
        expect(DeactivateArkJob).to_not receive(:perform_later).with(ark)
        subject.destroy(env)
      end
    end

  end

end
