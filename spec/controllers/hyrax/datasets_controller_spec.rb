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
        it { is_expected.to_not render_template(partial: '_dataset_versions') }
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
        it { is_expected.to be_redirect }
      end
      describe "with version 2 of 3" do
        let(:current_version) { v2 }
        it { is_expected.to be_redirect }
      end
      describe "with version 3 of 3" do
        let(:current_version) { v3 }
        it { is_expected.to render_template(:show) }
      end
    end
  end

  describe "#assign_register_doi" do
    let(:ds) { FactoryBot.create(:dataset) }
    let(:user) { FactoryBot.create(:user) }
    before { sign_in user }
    describe 'user can assign and register DOIs' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:assign_register_doi, an_instance_of(Dataset)) { true }
      end
      describe 'DOI is assignable to object' do
        before { allow_any_instance_of(Dataset).to receive(:doi_assignable?) { true } }
        it 'enqueues the assignment and registration job and notifies the user' do
          expect(AssignRegisterDoiJob).to receive(:perform_later).with(ds)
          post :assign_register_doi, params: {id: ds.id }
          expect(flash[:notice]).to eq(I18n.t('rdr.doi.assigment_registration_job_enqueued'))
          expect(response).to redirect_to("#{main_app.hyrax_dataset_path(ds)}?locale=en")
        end
      end
      describe 'DOI is not assignable to object' do
        before { allow_any_instance_of(Dataset).to receive(:doi_assignable?) { false } }
        it 'does not enqueue the assignment and registration job and notifies the user' do
          expect(AssignRegisterDoiJob).to_not receive(:perform_later).with(ds)
          post :assign_register_doi, params: {id: ds.id }
          expect(flash[:alert]).to eq(I18n.t('rdr.doi.not_assignable'))
          expect(response).to redirect_to("#{main_app.hyrax_dataset_path(ds)}?locale=en")
        end
      end
    end
    describe 'user cannot assign and register DOIs' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:assign_register_doi, an_instance_of(Dataset)) { false }
      end
      describe 'DOI is assignable to object' do
        before { allow_any_instance_of(Dataset).to receive(:doi_assignable?) { true } }
        it 'does not enqueue the assignment and registration job and notifies the user' do
          expect(AssignRegisterDoiJob).to_not receive(:perform_later).with(ds)
          post :assign_register_doi, params: {id: ds.id }
          expect(flash[:alert]).to eq(I18n.t('unauthorized.assign_register_doi.all'))
          expect(response).to redirect_to("#{main_app.root_path}?locale=en")
        end
      end
      describe 'DOI is not assignable to object' do
        before { allow_any_instance_of(Dataset).to receive(:doi_assignable?) { false } }
        it 'does not enqueue the assignment and registration job and notifies the user' do
          expect(AssignRegisterDoiJob).to_not receive(:perform_later).with(ds)
          post :assign_register_doi, params: {id: ds.id }
          expect(flash[:alert]).to eq(I18n.t('unauthorized.assign_register_doi.all'))
          expect(response).to redirect_to("#{main_app.root_path}?locale=en")
        end
      end
    end
  end

end
