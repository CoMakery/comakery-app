require 'rails_helper'

describe BetaSignupsController do
  describe '#new' do
    it 'works' do
      get :new

      expect(response.status).to eq(200)
      expect(assigns[:beta_signup]).to be_new_record
    end

    it 'sticks emails into the form field from params' do
      get :new, email_address: 'bob@example.com'

      expect(response.status).to eq(200)
      expect(assigns[:beta_signup].email_address).to eq('bob@example.com')
    end
  end

  describe '#create' do
    context 'with existing beta signup matches by email, if more than one updates last' do
      let!(:beta_signup1) { create(:beta_signup, email_address: 'bob@example.com', opt_in: false) }
      let!(:beta_signup2) { create(:beta_signup, email_address: 'bob@example.com', opt_in: false) }

      it 'updates the beta signup' do
        expect do
          post :create, beta_signup: { email_address: 'bob@example.com' }, commit: Views::BetaSignups::New::OPT_IN_SUBMIT_BUTTON_TEXT
        end.not_to change { BetaSignup.count }

        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to eq('You have been added to the beta waiting list. Invite more people from your slack to sign up for the beta. We will be inviting the slack teams with the most beta list signups first!')

        expect(beta_signup1.reload.opt_in).to eq(false)
        expect(beta_signup2.reload.opt_in).to eq(true)
      end
    end

    context "when the user goes straight to the beta sign up page so there isn't a beta signup" do
      it 'creates a signup based on a valid email' do
        expect do
          post :create, beta_signup: { email_address: 'bob@example.com' }, commit: Views::BetaSignups::New::OPT_IN_SUBMIT_BUTTON_TEXT
        end.to change { BetaSignup.count }.by(1)

        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to be

        beta_signup = BetaSignup.last
        expect(beta_signup.email_address).to eq('bob@example.com')
        expect(beta_signup.opt_in).to eq(true)
      end

      context 'when user enters bad email' do
        it 'tells the user' do
          expect do
            post :create, beta_signup: { email_address: 'not an email' }, commit: Views::BetaSignups::New::OPT_IN_SUBMIT_BUTTON_TEXT
          end.not_to change { BetaSignup.count }

          expect(response.status).to eq(200)
          expect(flash[:errors]).to be
          expect(assigns[:beta_signup]).to be_a(BetaSignup)
        end
      end

      context 'when user opts out' do
        it 'tells the user' do
          expect do
            post :create, beta_signup: { email_address: 'not an email' }, commit: Views::BetaSignups::New::OPT_OUT_SUBMIT_BUTTON_TEXT
          end.not_to change { BetaSignup.count }

          expect(response.status).to eq(302)
          expect(flash[:notice]).to eq('You have not been added to the beta waiting list. Check back to see new public CoMakery projects!')
        end
      end
    end
  end
end
