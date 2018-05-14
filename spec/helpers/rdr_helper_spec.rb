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

  describe '#truncate_description_and_iconify_auto_link' do
    let(:text1) { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.' }
    let(:trunc1) { 'Lorem ipsum dolor sit amet, consectetur...' }
    let(:text2) { 'Aenean eu convallis mi, vel elementum orci. Aenean fermentum augue ligula, et vehicula tellus pharetra sit amet. Nulla scelerisque nec risus non efficitur. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Sed tempus, enim et pellentesque sagittis, diam dui vestibulum sem, vel tincidunt nunc odio.' }
    let(:trunc2) { 'Aenean eu convallis mi, vel elementum orci....' }
    let(:text3) { 'Lorem ipsum dolor sit posuere.' }
    let(:document) { double('SolrDocument') }
    let(:config) { double }
    let(:field) { double('String') }
    let(:original_args) { { document: document, value: [ text1, text2, text3 ], config: config, field: field } }
    let(:truncated_args) { { document: document, value: [ trunc1, trunc2, text3 ], config: config, field: field } }
    before do
      Rdr.description_truncation_length_index_view = 50
    end
    it 'truncates the description field values and calls the iconify_auto_link helper on the result' do
      expect(helper).to receive(:iconify_auto_link).with(truncated_args)
      helper.truncate_description_and_iconify_auto_link(original_args)
    end
  end

end
