require 'rails_helper'

RSpec.describe RdrHelper, type: :helper do

  describe '#render_on_behalf_of' do
    describe 'not on behalf of' do
      it 'renders "Yourself"' do
        expect(helper.render_on_behalf_of('')).to eq('Yourself')
      end
    end
    describe 'on behalf of' do
      let(:user_key) { 'a@b.edu' }
      before do
        allow(User).to receive(:find_by_user_key).with(user_key) { user }
      end
      describe 'user display name available' do
        let(:display_name) { 'A.B. User' }
        let(:user) { double('User', user_key: user_key, display_name: display_name) }
        it 'renders the display name' do
          expect(helper.render_on_behalf_of(user_key)).to eq(display_name)
        end
      end
      describe 'user display name not available' do
        let(:user) { double('User', user_key: user_key, display_name: nil) }
        it 'renders the user_key' do
          expect(helper.render_on_behalf_of(user_key)).to eq(user_key)
        end
      end
    end
  end
end
