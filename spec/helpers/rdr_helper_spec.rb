require 'rails_helper'

RSpec.describe RdrHelper, type: :helper do

  describe '#recent_dataset_entry' do
    let(:title) { 'Test Title' }
    let(:doc) { SolrDocument.new }
    before do
      allow(doc).to receive(:title) { [ title ] }
    end
    describe 'has bibliographic citation' do
      let(:citation) { 'bibliographic citation' }
      before do
        allow(doc).to receive(:bibliographic_citation) { [ citation ] }
      end
      it 'returns the bibliographic citation' do
        expect(helper.recent_dataset_entry(doc)).to eq(citation)
      end
    end
    describe 'does not have bibiliographic citation' do
      it 'returns the title' do
        expect(helper.recent_dataset_entry(doc)).to eq(title)
      end
    end
  end

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

  describe '#expandable_iconify_auto_link' do
    before do
      Rdr.expandable_text_word_cutoff = 10
      allow(helper).to receive(:iconify_auto_link).and_return('Foo &lt; <a href="http://www.example.com"><span class="glyphicon glyphicon-new-window"></span> http://www.example.com</a>. &amp; More text')
    end
    context "value has more words than the cutoff" do
      let(:value) { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.' }
      it "should have a Read More link" do
        expect(helper.expandable_iconify_auto_link(value)).to include('[Read More]')
      end
      it "should call Hyrax's iconify_auto_link method for each part of the split string" do
        expect(helper).to receive(:iconify_auto_link).with('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod')
        expect(helper).to receive(:iconify_auto_link).with('tempor incididunt ut labore.')
        helper.expandable_iconify_auto_link(value)
      end
    end
    context "value has fewer words than the cutoff" do
      let(:value) { 'Aenean eu convallis mi.' }
      it "should not have a Read More link" do
        expect(helper.expandable_iconify_auto_link(value)).not_to include('[Read More]')
      end
    end
  end

end
