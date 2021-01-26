class Api::V1::HotWalletAddressesController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::AuthorizableByProjectKey
  include Api::V1::Concerns::AuthorizableByProjectPolicy
  include Api::V1::Concerns::RequiresAnAuthorization

  before_action :verify_hot_wallet, only: :create

  def create
    create_hot_wallet

    if @create_hot_wallet&.persisted?
      render 'api/v1/wallets/index.json', status: :created
    else
      @errors = @create_hot_wallet.errors
      render 'api/v1/error.json', status: :bad_request
    end
  end

  private

    def create_hot_wallet
      @create_hot_wallet ||= project.create_hot_wallet(wallet_params)
    end

    def project
      @project ||= project_scope.find(params[:project_id])
    end

    def wallet_params
      params.fetch(:body, {}).fetch(:data, {}).fetch(:hot_wallet, {}).permit(:address, :name, :_blockchain)
    end

    def verify_hot_wallet
      if project.hot_wallet.present?
        @errors = { hot_wallet: 'already exists' }

        render 'api/v1/error.json', status: :unprocessable_entity
      end
    end
end
