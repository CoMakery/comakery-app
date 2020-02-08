class Api::V1::VerificationsController < Api::V1::ApiController
  # GET /api/v1/accounts/1/verifications
  def index
    fresh_when verifications, public: true
  end

  # POST /api/v1/accounts/1/verifications
  def create
    verification = account.verifications.new(verification_params)

    if verification.save
      verifications

      render 'index.json', status: 201
    else
      @errors = verification.errors

      render 'api/v1/error.json', status: 400
    end
  end

  private

    def account
      @account ||= whitelabel_mission.managed_accounts.find_by!(managed_account_id: params[:account_id])
    end

    def verifications
      @verifications ||= paginate(account.verifications)
    end

    def verification_params
      params.fetch(:body, {}).fetch(:data, {}).fetch(:verification, {}).permit(
        :passed,
        :verification_type,
        :max_investment_usd,
        :created_at
      )
    end
end
