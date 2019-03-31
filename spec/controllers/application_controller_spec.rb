require 'rails_helper'

class FoosController < ApplicationController; end

describe ApplicationController do
  controller FoosController do
    skip_before_action :require_login
    skip_after_action :verify_policy_scoped

    def index
      raise ActiveRecord::RecordNotFound
    end

    def new
      raise Slack::Web::Api::Error, 'boom'
    end

    def show
      raise Pundit::NotAuthorizedError, 'boooom'
    end
  end

  describe 'check_age' do
    it 'redirects underage users to build profile page' do
      account = create(:account)
      account.date_of_birth = 17.years.ago
      account.save(validate: false)
      login account

      get :index
      expect(response).to redirect_to build_profile_accounts_path
      expect(flash[:alert]).to eq('Sorry, you must be 18 years or older to use this website')
    end
  end

  describe 'require_build_profile' do
    it 'renders build profile page for invalid accounts' do
      account = create(:account)
      account.country = nil
      account.specialty = nil
      account.save(validate: false)
      login account

      get :index
      expect(response).to render_template('accounts/build_profile')
      expect(assigns[:account]).to eq(account)
      expect(assigns[:skip_validation]).to be true
      expect(flash[:error]).to eq('Please complete your profile info for Country, Specialty')
    end
  end

  describe 'errors' do
    describe 'ActiveRecord::RecordNotFound' do
      it 'redirects to 404 page' do
        get :index

        expect(response).to redirect_to '/404.html'
      end

      it 'raises error in dev env' do
        current_env = Rails.env
        Rails.env = 'development'
        begin
          expect { get :index }.to raise_error(ActiveRecord::RecordNotFound)
        ensure
          Rails.env = current_env
        end
      end
    end

    describe 'Slack::Web::Api::Error' do
      it 'redirects to logout page' do
        expect(Rails.logger).to receive(:error)
        session[:account_id] = 432

        get :new

        expect(session).not_to have_key(:account_id)
        expect(response).to redirect_to root_url
        expect(flash[:error]).to eq('Error talking to Slack, sorry!')
      end
    end

    describe 'Pundit::NotAuthorizedError' do
      it 'redirects to root path and logs the error' do
        expect(Rails.logger).to receive(:error)

        get :show, params: { id: 1 }

        expect(response).to redirect_to root_url
      end
    end
  end
end
