# Generated via
#  `rails generate hyrax:work Dataset`
require 'rails_helper'

RSpec.describe Hyrax::DatasetsController do

  describe "#show" do
    render_views
    describe "flash" do
      let!(:v1) { FactoryBot.create(:dataset, :public, doi: "http://example.com/my_doi_v1", is_replaced_by: "http://example.com/my_doi_v2") }
      let!(:v2) { FactoryBot.create(:dataset, :public, doi: "http://example.com/my_doi_v2", replaces: "http://example.com/my_doi_v1") }
      describe "when the record is the latest dataset version" do
        it "does not render a flash message" do
          get :show, params: { id: v2 }
          expect(response.body).not_to match(/previous version/)
        end
      end
      describe "when the record is not the latest dataset version" do
        it "renders a flash message" do
          get :show, params: { id: v1 }
          expect(response.body).to match(/previous version/)
        end
        it "renders a link to the latest version" do
          get :show, params: { id: v1 }
          expect(response.body).to match(/dataset_version=latest/)
        end
      end
    end

    describe "versions partial" do
      subject { get :show, params: { id: v1 } }
      describe "when the dataset has one version" do
        let(:v1) { FactoryBot.create(:dataset, :public) }
        it { is_expected.to render_template(partial: '_dataset_versions') }
      end
      describe "when the dataset has multiple versions" do
        let!(:v1) { FactoryBot.create(:dataset, :public, doi: "http://example.com/my_doi_v1", is_replaced_by: "http://example.com/my_doi_v2") }
        let!(:v2) { FactoryBot.create(:dataset, :public, doi: "http://example.com/my_doi_v2", replaces: "http://example.com/my_doi_v1") }
        it { is_expected.to render_template(partial: '_dataset_versions') }
      end
    end

    describe "?dataset_version=latest" do
      subject { get :show, params: { id: current_version, dataset_version: "latest" } }
      let!(:v1) { FactoryBot.create(:dataset, :public, doi: "http://example.com/my_doi_v1", is_replaced_by: "http://example.com/my_doi_v2") }
      let!(:v2) { FactoryBot.create(:dataset, :public, doi: "http://example.com/my_doi_v2", replaces: "http://example.com/my_doi_v1", is_replaced_by: "http://example.com/my_doi_v3") }
      let!(:v3) { FactoryBot.create(:dataset, :public, doi: "http://example.com/my_doi_v3", replaces: "http://example.com/my_doi_v2") }
      describe "with version 1 of 3" do
        let(:current_version) { v1 }
        it { is_expected.to redirect_to(hyrax_dataset_path(v3)) }
      end
      describe "with version 2 of 3" do
        let(:current_version) { v2 }
        it { is_expected.to redirect_to(hyrax_dataset_path(v3)) }
      end
      describe "with version 3 of 3" do
        let(:current_version) { v3 }
        it { is_expected.to render_template(:show) }
      end
    end
  end

end
