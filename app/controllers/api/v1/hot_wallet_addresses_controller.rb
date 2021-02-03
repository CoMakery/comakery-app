class Api::V1::HotWalletAddressesController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByProjectKey
  include Api::V1::Concerns::RequiresAnAuthorization

  before_action :verify_hot_wallet, only: :create

  def create
    @hot_wallet = project.build_hot_wallet(wallet_params)
    @hot_wallet.source = :hot_wallet
    @hot_wallet.account = project.account

    if @hot_wallet.save
      project.save
      render 'show.json', status: :created
    else
      @errors = @hot_wallet.errors
      render 'api/v1/error.json', status: :bad_request
    end
  end

  private

    def project
      @project ||= Project.find(params.require(:project_id))
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
