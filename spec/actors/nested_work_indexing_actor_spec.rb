require 'rails_helper'

RSpec.describe NestedWorkIndexingActor do

  subject { described_class.new(env) }

  let(:user) { FactoryBot.build(:user) }
  let(:ability) { Ability.new(user) }
  let(:next_actor) { double }

  before do
    allow(subject).to receive(:next_actor) { next_actor }
  end

  describe '#create' do
    let(:dataset) { Dataset.new(id: 'test', title: [ 'Testing' ], depositor: user.user_key) }
    let(:env) { Hyrax::Actors::Environment.new(dataset, ability, attributes) }
    before do
      allow(next_actor).to receive(:create) { true }
      allow(ActiveFedora::Base).to receive(:find).with(dataset.id) { dataset }
    end
    describe 'work is not nested' do
      let(:attributes) { { title: [ "Testing" ] } }
      it 'does not index the work' do
        expect_any_instance_of(Dataset).to_not receive(:update_index)
        subject.create(env)
      end
    end
    describe 'work is nested' do
      let(:attributes) { { title: [ "Testing" ], in_works_ids: [ 'parent' ] } }
      it 'indexes the work' do
        expect_any_instance_of(Dataset).to receive(:update_index)
        subject.create(env)
      end
    end
  end

  describe '#update' do
    let(:datasets) { FactoryBot.create_list( :dataset, 2, user: user) }
    let(:env) { Hyrax::Actors::Environment.new(datasets[0], ability, attributes) }
    before do
      allow(next_actor).to receive(:update) { true }
    end
    describe 'nested work is added' do
      let(:attributes) { { id: datasets[0].id, title: datasets[0].title,
                           work_members_attributes: { "0"=>{ "id"=>"#{datasets[1].id}", "_destroy"=>"false" } } } }
      it 'updates the nested work index' do
        expect_any_instance_of(Dataset).to receive(:update_index)
        subject.update(env)
      end
    end
    describe 'nested work is removed' do
      let(:attributes) { { id: datasets[0].id, title: datasets[0].title,
                           work_members_attributes: { "0"=>{ "id"=>"#{datasets[1].id}", "_destroy"=>"true" } } } }
      before do
        datasets[0].ordered_members << datasets[1]
        datasets[0].save!
      end
      it 'updates the nested work index' do
        expect_any_instance_of(Dataset).to receive(:update_index)
        subject.update(env)
      end
    end
    describe 'no changes to nested works' do
      let(:attributes) { { id: datasets[0].id, title: datasets[0].title,
                           work_members_attributes: { "0"=>{ "id"=>"#{datasets[1].id}", "_destroy"=>"false" } } } }
      before do
        datasets[0].ordered_members << datasets[1]
        datasets[0].save!
      end
      it 'does not update the index' do
        expect_any_instance_of(Dataset).to_not receive(:update_index)
        subject.update(env)
      end
    end
  end

end
