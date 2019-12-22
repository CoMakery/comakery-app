class Api::V1::AccountsController < Api::V1::ApiController
  # GET /api/v1/accounts/1
  def show
    fresh_when account
  end

  # PATCH/PUT /api/v1/accounts/1
  def update
    if account.update(account_params)
      redirect_to api_v1_account_path(account)
    else
      @errors = account.errors

      render 'api/v1/error.json', status: 400
    end
  end

  private

    def account
      @account ||= (Account.find_by(id: params[:id]) || Account.find_by!(email: params[:id]))
    end

    def account_params
      params.fetch(:account, {}).permit(
        :first_name,
        :last_name,
        :nickname,
        :image,
        :country,
        :date_of_birth,
        :ethereum_wallet,
        :qtum_wallet,
        :cardano_wallet,
        :bitcoin_wallet,
        :eos_wallet,
        :tezos_wallet
      )
    end
end
