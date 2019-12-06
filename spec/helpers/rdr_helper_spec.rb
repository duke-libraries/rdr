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

  describe '#vertical_breadcrumb_node_position' do
    context 'current work is not deeply nested (three or fewer total ancestor nodes)' do
      let(:pos) { 2 }
      let(:total_nodes) { 3 }
      it 'should treat all nodes as close ancestors' do
        expect(helper.vertical_breadcrumb_node_position(pos,total_nodes)).to eq('close-ancestor')
      end
    end
    context 'work is the final ancestor (direct parent)' do
      let(:pos) { 8 }
      let(:total_nodes) { 8 }
      it 'should consider the node to be a close ancestor' do
        expect(helper.vertical_breadcrumb_node_position(pos,total_nodes)).to eq('close-ancestor')
      end
    end
    context 'top-level work in a deeply nested hierarchy' do
      let(:pos) { 1 }
      let(:total_nodes) { 23 }
      it 'should consider the node as top-level' do
        expect(helper.vertical_breadcrumb_node_position(pos,total_nodes)).to eq('top-of-many-ancestors')
      end
    end
    context 'work is neither top-level nor a direct parent, and is in a deep hierarchy' do
      let(:pos) { 5 }
      let(:total_nodes) { 17 }
      it 'should consider the node middle-level (e.g., to collapse it in display)' do
        expect(helper.vertical_breadcrumb_node_position(pos,total_nodes)).to eq('middle-ancestor')
      end
    end
  end

end
