class Auth::EthController < ApplicationController
  skip_before_action :require_login, :check_age, :require_build_profile
  skip_after_action :verify_authorized, :verify_policy_scoped
  before_action :redirect_if_signed_in

  # GET /auth/eth/new
  def new
    @nonce = Comakery::Auth::Eth.random_stamp("Authentication Request")
    Rails.cache.write("auth_eth::nonce::#{auth_params[:public_address]}", @nonce, expires_in: 1.hour)
  end

  # POST /auth/eth
  def create
    auth = Comakery::Auth::Eth.new(
      Rails.cache.read("auth_eth::nonce::#{auth_params[:public_address]}"),
      auth_params[:signature],
      auth_params[:public_address]
    )

    if auth.valid?
      account = Account.find_or_initialize_by(ethereum_wallet: auth_params[:public_address])
      account.save(validate: false) if account.new_record?

      session[:account_id] = account.id
      redirect_to my_tasks_path
    else
      head 401
    end
  end

  private

    def auth_params
      params.fetch(:body, {}).fetch(:data, {}).fetch(:auth_eth, {}).permit(
        :public_address,
        :signature
      )
    end
end
