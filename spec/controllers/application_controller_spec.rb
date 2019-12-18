require 'rails_helper'

class FoosController < ApplicationController; end

describe ApplicationController do
  controller FoosController do
    skip_before_action :require_login
    skip_after_action :verify_policy_scoped

    before_action :redirect_back, only: %i[index]
    before_action :create_interest_from_session, only: %i[index]

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

  describe 'redirect_back' do
    let!(:account) { create(:account) }
    let!(:invalid_account) { create(:account) }
    let!(:unconfirmed_account) { create(:account) }

    it 'redirects if account is valid and confirmed' do
      login(account)
      get(:index, session: { return_to: '/hi' })
      expect(response).to redirect_to('/hi')
    end

    it 'doesnt redirect if account is invalid' do
      invalid_account.first_name = nil
      invalid_account.save(validate: false)

      login(invalid_account)
      get(:index, session: { return_to: '/hi' })
      expect(response).not_to redirect_to('/hi')
    end

    it 'doesnt redirect if account is not confirmed' do
      unconfirmed_account.email_confirm_token = 'abc'
      unconfirmed_account.save

      login(unconfirmed_account)
      get(:index, session: { return_to: '/hi' })
      expect(response).not_to redirect_to('/hi')
    end
  end

  describe 'create_interest_from_session' do
    let!(:account) { create(:account) }
    let!(:project) { create(:project) }

    it 'creates interest for project stored in session' do
      login(account)
      get(:index, session: { interested_in_project: project.id })

      expect(account.interested?(project.id)).to be_truthy
    end
  end

  describe 'task_to_props(task)' do
    let!(:award) { create :award }

    it 'serializes task and includes data necessary for task react component' do
      result = controller.task_to_props(award)
      expect(result.class).to eq(Hash)
      expect(result).to include(:mission)
      expect(result).to include(:token)
      expect(result).to include(:project)
      expect(result).to include(:specialty)
      expect(result).to include(:issuer)
      expect(result).to include(:contributor)
      expect(result).to include(:experience_level_name)
      expect(result).to include(:updated_at)
      expect(result).to include(:image_url)
      expect(result).to include(:submission_image_url)
      expect(result).to include(:payment_url)
      expect(result).to include(:details_url)
      expect(result).to include(:start_url)
      expect(result).to include(:submit_url)
      expect(result).to include(:accept_url)
      expect(result).to include(:reject_url)
    end
  end

  describe 'current_domain' do
    it 'returds request domain including all subdomains' do
      expect(controller.current_domain).to eq('test.host')
    end
  end

  describe 'set_whitelabel_mission' do
    let!(:whitelabel_mission) { create(:mission, whitelabel: true) }

    it 'assigns whitelabel mission which matches current_domain' do
      whitelabel_mission.update(whitelabel_domain: 'test.host')

      get :index
      expect(assigns[:whitelabel_mission]).to eq(whitelabel_mission)
    end

    it 'doesnt assign whitelabel mission' do
      get :index
      expect(assigns[:whitelabel_mission]).to be_nil
    end
  end

  describe 'set_project_scope' do
    let!(:whitelabel_mission) { create(:mission, whitelabel: true) }
    let!(:whitelabel_project) { create(:project, mission: whitelabel_mission) }
    let!(:project) { create(:project) }

    it 'sets project scope to whitelabel_mission projects' do
      whitelabel_mission.update(whitelabel_domain: 'test.host')

      get :index
      expect(assigns[:project_scope].all).to include(whitelabel_project)
      expect(assigns[:project_scope].all).not_to include(project)
    end

    it 'sets project scope to all projects excluding whitelabel ones' do
      get :index
      expect(assigns[:project_scope].all).not_to include(whitelabel_project)
      expect(assigns[:project_scope].all).to include(project)
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
