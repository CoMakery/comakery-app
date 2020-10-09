class Api::V1::AccountsController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::RequiresAnAuthorization
  include Api::V1::Concerns::RequiresSignature
  include Api::V1::Concerns::RequiresWhitelabelMission

  # GET /api/v1/accounts/1
  def show
    fresh_when account, public: true
  end

  # GET /api/v1/accounts/1/token_balances
  def token_balances
    account
  end

  # POST /api/v1/accounts
  def create
    account = whitelabel_mission.managed_accounts.create(account_params)
    account.name_required = true
    account.specialty = Specialty.default

    if account.save
      @account = account

      render 'show.json', status: :created
    else
      @errors = account.errors

      render 'api/v1/error.json', status: :bad_request
    end
  end

  # PATCH/PUT /api/v1/accounts/1
  def update
    if account.update(account_params)
      render 'show.json', status: :ok
    else
      @errors = account.errors

      render 'api/v1/error.json', status: :bad_request
    end
  end

  private

    def account
      @account ||= (whitelabel_mission.managed_accounts.find_by(managed_account_id: params[:id]) || whitelabel_mission.managed_accounts.find_by!(managed_account_id: params[:account_id]))
    end

    def account_params
      params.fetch(:body, {}).fetch(:data, {}).fetch(:account, {}).permit(
        :email,
        :managed_account_id,
        :first_name,
        :last_name,
        :nickname,
        :image,
        :country,
        :date_of_birth
      )
    end
end
