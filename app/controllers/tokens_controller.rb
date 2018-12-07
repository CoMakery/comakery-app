class TokensController < ApplicationController
  before_action :redirect_unless_admin
  before_action :set_token, only: %i[show edit update]
  before_action :set_coin_types, only: %i[new show edit]
  before_action :set_ethereum_networks, only: %i[new show edit]
  before_action :set_blockchain_networks, only: %i[new show edit]
  before_action :set_generic_props, only: %i[new show edit]

  def index
    @tokens = policy_scope(Token)

    render component: 'TokenIndex', props: { tokens: @tokens }
  end

  def new
    @token = Token.create
    authorize @token
    
    @props[:token] = @token.serializable_hash
    render component: 'TokenForm', props: @props, prerender: false
  end

  def create
    @token = Token.create token_params
    authorize @token

    if @token.save
      render json: { message: 'Token created' }, status: :created
    else
      errors  = @token.errors.messages.map { |k, v| [k, v.to_sentence] }.to_s
      message = @token.errors.full_messages.join(', ')
      render json: { message: message, errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @token

    @props[:form_action] = 'PATCH'
    render component: 'TokenForm', props: @props
  end

  def edit
    authorize @token

    @props[:form_action] = 'PATCH'
    render component: 'TokenForm', props: @props
  end

  def update
    authorize @token

    if @token.update token_params
      render json: { message: 'Token updated' }, status: :ok
    else
      errors  = @token.errors.messages.map { |k, v| [k, v.to_sentence] }.to_s
      message = @token.errors.full_messages.join(', ')
      render json: { message: message, errors: errors }, status: :unprocessable_entity
    end
  end

  private

  def redirect_unless_admin
    redirect_to root_path unless current_account.comakery_admin?
  end

  def set_token
    @token = Token.find(params[:id]).decorate
  end
  
  def set_coin_types
    @coin_types = Token.coin_types.invert
  end
  
  def set_ethereum_networks
    @ethereum_networks = Token.ethereum_networks.invert
  end
  
  def set_blockchain_networks
    @blockchain_networks = Token.blockchain_networks.invert
  end

  def set_generic_props
    @props = {
      token: @token&.serializable_hash,
      coin_types: @coin_types,
      ethereum_networks: @ethereum_networks,
      blockchain_networks: @blockchain_networks,
      form_url: tokens_path,
      form_action: 'POST',
      url_on_success: tokens_path,
      csrf_token: form_authenticity_token
    }
  end

  def token_params
    params.require(:token).permit(
      :name,
      :ethereum_enabled,
      :logo_image,
      :coin_type,
      :denomination,
      :ethereum_network,
      :ethereum_contract_address,
      :blockchain_network,
      :contract_address,
      :symbol,
      :decimal_places
    )
  end
end
