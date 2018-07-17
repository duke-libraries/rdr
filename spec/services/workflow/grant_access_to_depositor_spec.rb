require 'rails_helper'

# Modeled on Hyrax 'spec/services/hyrax/workflow/grant_edit_to_depositor_spec.rb'

RSpec.describe Workflow::GrantAccessToDepositor do
  let!(:depositor) { FactoryBot.create(:user) }
  let(:user) { User.new }

  let(:workflow_method) { described_class }

  describe '.call' do
    subject do
      described_class.call(target: work, user: user)
    end

    describe 'work' do
      let(:work) { FactoryBot.create(:dataset_without_access, depositor: depositor.user_key) }
      describe 'curator' do
        before do
          allow(User).to receive(:curators) { [ depositor.user_key ] }
        end
        it 'adds edit access' do
          expect{ subject }.to change { work.edit_users }.from([]).to([ depositor.user_key ])
        end
      end
      describe 'not curator' do
        it 'does not add edit access' do
          expect{ subject }.to_not change { work.edit_users }
        end
        it 'adds read access' do
          expect{ subject }.to change { work.read_users }.from([]).to([ depositor.user_key ])
        end
      end
    end

    describe 'attached FileSets' do
      let(:work) { FactoryBot.create(:dataset_with_one_file, user: depositor) }
      let(:file_set) do
        work.members.first.tap do |file_set|
          file_set.update(edit_users: [])
          file_set.update(read_users: [])
        end
      end
      describe 'curator' do
        before do
          allow(User).to receive(:curators) { [ depositor.user_key ] }
        end
        it 'adds edit access' do
          expect{ subject }.to change { file_set.reload.edit_users }.from([]).to([ depositor.user_key ])
        end
      end
      describe 'not curator' do
        it 'does not add edit access' do
          expect{ subject }.to_not change { file_set.reload.edit_users }
        end
        it 'adds read access' do
          expect{ subject }.to change { file_set.reload.read_users }.from([]).to([ depositor.user_key ])
        end
      end

    end
  end
end
