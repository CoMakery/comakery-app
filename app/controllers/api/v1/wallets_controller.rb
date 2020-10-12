class Api::V1::WalletsController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::RequiresAnAuthorization
  include Api::V1::Concerns::RequiresSignature
  include Api::V1::Concerns::RequiresWhitelabelMission

  # GET /api/v1/accounts/1/wallets
  def index
    fresh_when wallets, public: true
  end

  # POST /api/v1/wallets
  def create
    wallet = account.wallets.new(wallet_params)

    if wallet.save
      wallets

      render 'index.json', status: :created
    else
      @errors = wallet.errors

      render 'api/v1/error.json', status: :bad_request
    end
  end

  # DELETE /api/v1/accounts/1/wallets/1
  def destroy
    wallet.destroy
    wallets

    render 'index.json', status: :ok
  end

  # POST /api/v1/accounts/1/wallets/1/password_reset
  def password_reset
    wallet
    redirect_url

    render 'password_reset.json', status: :ok
  end

  private

    def account
      @account ||= whitelabel_mission.managed_accounts.find_by!(managed_account_id: params[:account_id])
    end

    def wallets
      @wallets ||= paginate(account.wallets)
    end

    def wallet
      @wallet ||= account.wallets.find(params[:id])
    end

    def wallet_params
      r = params.fetch(:body, {}).fetch(:data, {}).fetch(:wallet, {}).permit(
        :blockchain,
        :address,
        :source,
        :provision
      )

      r[:_blockchain] = r[:blockchain]
      r.delete(:blockchain)
      r.delete(:provision)
      r
    end

    def redirect_url
      @redirect_url ||= params.fetch(:body, {}).fetch(:data, {}).fetch(:redirect_url, nil)
    end
end
