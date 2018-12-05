class TokensController < ApplicationController
  before_action :assign_current_account
  before_action :redirect_unless_admin
  before_action :set_token, only: %i[show edit update]

  def index
    @tokens = policy_scope(Token)

    render component: 'TokenIndex', props: { tokens: @tokens }
  end

  def new
    @token = Token.create
    authorize @token

    render component: 'TokenNew', props: { token: @token }
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

    render component: 'TokenShow', props: { token: @token }
  end

  def edit
    authorize @token

    render component: 'TokenEdit', props: { token: @token }
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

  def assign_current_account
    @current_account_deco = current_account&.decorate
  end

  def redirect_unless_admin
    redirect_to root_path unless current_account.comakery_admin?
  end

  def set_token
    @token = Token.find(params[:id]).decorate
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
