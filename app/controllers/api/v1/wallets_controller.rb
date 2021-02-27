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
    @wallets, @errors = WalletCreator.new(account: account).call(wallets_params)

    if @errors.empty?
      render 'index.json', status: :created
    else
      render 'api/v1/error.json', status: :bad_request
    end
  end

  # PATCH/PUT /api/v1/accounts/1/wallets/1
  def update
    result = MakePrimaryWallet.call(account: account, wallet: wallet)

    if result.success?
      render 'show.json', status: :ok
    else
      @errors = result.wallet.errors
      render 'api/v1/error.json', status: :bad_request
    end
  end

  # GET /api/v1/accounts/1/wallets/1
  def show
    fresh_when wallet, public: true
  end

  # DELETE /api/v1/accounts/1/wallets/1
  def destroy
    wallet.destroy

    if wallet.persisted?
      @errors = wallet.errors

      render 'api/v1/error.json', status: :bad_request
    else
      wallets

      render 'index.json', status: :ok
    end
  end

  # POST /api/v1/accounts/1/wallets/1/password_reset
  def password_reset
    ore_id_account = wallet.ore_id_account
    @auth_url = ore_id_account.service.authorization_url(redirect_url, nil, params.dig(:proof, :signature))
    ore_id_account.unclaimed!
    ore_id_account.schedule_password_update_sync

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

    def wallets_params
      wallets = params.fetch(:body, {}).fetch(:data, {}).require(:wallets)

      wallets.map do |wallet_params|
        wallet_params.permit(
          :blockchain, :address, :source, :name,
          tokens_to_provision: WalletCreator::Provision::ACCOUNT_RECORD_PARAMS
        )
      end
    end

    def wallet_params
      params.fetch(:body, {}).fetch(:data, {}).fetch(:wallet, {}).permit(:primary_wallet)
    end

    def redirect_url
      @redirect_url ||= params.fetch(:body, {}).fetch(:data, {}).fetch(:redirect_url, nil)
    end
end
