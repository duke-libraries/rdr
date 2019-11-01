require 'rails_helper'

RSpec.describe ExportFilesController, type: :controller do

  let(:work) { FactoryBot.create(:dataset) }

  describe "logged in user" do
    let(:user) { FactoryBot.create(:user) }
    before { sign_in user }
    describe "new" do
      specify {
        get :new, params: { id: work.id }
        expect(response).to render_template(:new)
      }
    end
    describe "create" do
      specify {
        post :create, params: { id: work.id, basename: "foo", confirmed: true }
        expect(response).to be_success
      }
    end
  end

  describe "no logged in user" do
    describe "new" do
      describe "email param not present" do
        describe "login param not present" do
          specify {
            get :new, params: { id: work.id }
            expect(response).to render_template(:unauthenticated)
          }
        end
        describe "login param present" do
          specify {
            get :new, params: { id: work.id, login: 1 }
            expect(controller.stored_location_for(:user)).to eq(export_files_path)
            expect(response.location).to match('users/sign_in')
          }
        end
      end
      describe "email param present" do
        specify {
          get :new, params: { email: "test@bar.com", id: work.id }
          expect(response).to render_template(:new)
        }
      end
    end
    describe "create" do
      specify {
        post :create, params: { id: work.id, basename: "foo", confirmed: true, email: "test@bar.com" }
        expect(response).to be_success
      }
    end
  end

end
