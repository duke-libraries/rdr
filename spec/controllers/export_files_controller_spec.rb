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
      describe "token param present" do
        let(:code) { SecureRandom.hex(6) }
        let(:email) { 'test@bar.com' }
        let(:token) { Base64.urlsafe_encode64([ email, code ].join('|')) }
        describe "valid token" do
          before do
            EmailVerification.create(email: email, code: code)
          end
          it 'has the decoded and verified email' do
            get :new, params: { id: work.id, token: token }
            expect(assigns[:email]).to eq(email)
          end
          it 'deletes the email verification database entry' do
            get :new, params: { id: work.id, token: token }
            expect(EmailVerification.where(email: email, code: code)).to be_empty
          end
          it 'renders the new template' do
            get :new, params: { id: work.id, token: token }
            expect(response).to render_template(:new)
          end
        end
        describe "invalid token" do
          it 'redirects to the work show page with a flash message' do
            get :new, params: { id: work.id, token: token }
            expect(flash[:error]).to eq(I18n.t('rdr.batch_export.email_verification.invalid_token_user_message'))
            expect(response).to redirect_to(hyrax_dataset_path(work))
          end
        end
      end
    end
    describe "unverified_email" do
      it "creates a email verification record" do
        expect{ post :unverified_email, params: { id: work.id, email: "test@bar.com" } }.to change(EmailVerification,
                                                                                                   :count).by(1)
      end
      it "sends a verification email" do
        expect{ post :unverified_email, params: { id: work.id, email: "test@bar.com" } }
                                                              .to change(ActionMailer::Base.deliveries, :count).by(1)
        sent_email = ActionMailer::Base.deliveries.last
        expect(sent_email.body).to include(Rdr.host_name)
      end
      it "renders the unverified email template" do
        post :unverified_email, params: { id: work.id, email: "test@bar.com" }
        expect(response).to render_template(:unverified_email)
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
