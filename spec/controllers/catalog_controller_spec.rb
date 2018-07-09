require 'rails_helper'

RSpec.describe CatalogController do

  describe "#index" do

    describe "latest_version set to true" do
      let!(:v1) { FactoryBot.create(:dataset, :public, doi: "http://example.com/my_doi_v1", is_replaced_by: "http://example.com/my_doi_v2") }
      let!(:v2) { FactoryBot.create(:dataset, :public, doi: "http://example.com/my_doi_v2", replaces: "http://example.com/my_doi_v1") }
      it "retrieves only the latest version" do
        get :index, params: { "latest_version" => 'true' }
        expect(assigns(:document_list).map(&:id)).to contain_exactly(v2.id)
      end
    end
    describe "latest_version is not set to true" do
      let!(:v1) { FactoryBot.create(:dataset, :public, doi: "http://example.com/my_doi_v1", is_replaced_by: "http://example.com/my_doi_v2") }
      let!(:v2) { FactoryBot.create(:dataset, :public, doi: "http://example.com/my_doi_v2", replaces: "http://example.com/my_doi_v1") }
      it "retrieves only the latest version" do
        get :index
        expect(assigns(:document_list).map(&:id)).to match_array [v2.id, v1.id]
      end
    end

    describe 'top level' do
      let(:parent) { FactoryBot.build(:dataset, :public) }
      let(:child) { FactoryBot.create(:dataset, :public) }
      before do
        parent.ordered_members << child
        parent.save!
      end
      describe "top_level set to true" do
        it "retrieves only the top level work" do
          get :index, params: { "top_level" => 'true' }
          expect(assigns(:document_list).map(&:id)).to contain_exactly(parent.id)
        end
      end
      describe "top_level is not set to true" do
        it "retrieves all the works" do
          get :index
          expect(assigns(:document_list).map(&:id)).to match_array [parent.id, child.id]
        end
      end
    end

  end
end
