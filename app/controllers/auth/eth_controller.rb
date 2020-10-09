class Auth::EthController < ApplicationController
  skip_before_action :require_login, :check_age, :require_build_profile
  skip_after_action :verify_authorized, :verify_policy_scoped
  before_action :redirect_if_signed_in
  before_action :validate_auth_params

  # GET /auth/eth/new
  def new
    @nonce = Comakery::Auth::Eth.random_stamp('Authentication Request ')
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
      account = Account.find_or_initialize_by(ethereum_auth_address: Eth::Address.new(auth_params[:public_address]).checksummed)

      if account.new_record?
        account.save(validate: false)
        account.wallets.create!(_blockchain: :ethereum, address: Eth::Address.new(auth_params[:public_address]).checksummed)
      end

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

    def validate_auth_params
      head 400 unless auth_params[:public_address] && Eth::Address.new(auth_params[:public_address]).valid?
    end
end
