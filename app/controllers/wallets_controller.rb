class WalletsController < ApplicationController
  before_action :set_hide_zero_balances
  before_action :set_wallet, only: %i[show edit update destroy algorand_opt_ins make_primary]
  after_action :authorize_wallet, only: %i[new create show edit update destroy algorand_opt_ins make_primary]
  helper_method :back_path

  # GET /wallets
  def index
    @wallets = wallets_collection.includes(balances: :token).order(:_blockchain)

    respond_to do |format|
      format.html {}
      format.json { render_collection_partial }
    end
  end

  def algorand_opt_ins
    content = render_to_string(
      partial: 'wallets/opt_ins_collection',
      formats: :html,
      layout: false,
      locals: { wallet: @wallet, opt_ins: @wallet.token_opt_ins }
    )
    render json: { content: content }, status: :ok
  end

  # GET /wallets/1
  def show; end

  # GET /wallets/new
  def new
    @wallet = policy_scope(Wallet).new

    respond_to do |format|
      format.html { redirect_to wallets_path }
      format.json do
        render_form_partial
      end
    end
  end

  # GET /wallets/1/edit
  def edit
    respond_to do |format|
      format.html { redirect_to wallets_path }
      format.json { render_form_partial }
    end
  end

  # POST /wallets
  def create
    @wallet = policy_scope(Wallet).new(wallet_params)

    if @wallet.save
      render json: { message: 'Wallet added' }, status: :created
    else
      render json: { message: @wallet.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /wallets/1
  def update
    if @wallet.update(wallet_params)
      render json: { message: 'Wallet updated' }, status: :ok
    else
      render json: { message: @wallet.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def make_primary
    result = MakePrimaryWallet.call(account: current_account, wallet: @wallet)

    if result.success?
      flash[:notice] = 'The wallet is successfully set as Primary'
    else
      flash[:error] = result.error
    end

    redirect_to wallets_path
  end

  # DELETE /wallets/1
  def destroy
    @wallet.destroy

    respond_to do |format|
      if @wallet.persisted?
        flash[:error] = @wallet.errors.full_messages.join(', ')
        format.html { redirect_to wallets_url }
      else
        format.html { redirect_to wallets_url, notice: 'Wallet removed' }
      end
    end
  end

  private

    def wallets_collection
      if session[:wallets__hide_zero_balances]
        Wallets::WithoutZeroBalances.call(relation: policy_scope(Wallet))
      else
        policy_scope(Wallet)
      end
    end

    def set_wallet
      @wallet = policy_scope(Wallet).find(params[:id])
    end

    def set_hide_zero_balances
      if params[:hide_zero_balances].nil?
        session[:wallets__hide_zero_balances] ||= false
      else
        session[:wallets__hide_zero_balances] = params[:hide_zero_balances] == 'true'
      end
    end

    def render_collection_partial
      content = render_to_string(
        partial: 'wallets/wallets_collection',
        formats: :html,
        layout: false,
        locals: { wallets: @wallets }
      )
      render json: { content: content }, status: :ok
    end

    def render_form_partial
      content = render_to_string(
        partial: 'wallets/form',
        formats: :html,
        layout: false,
        locals: { wallet: @wallet }
      )
      render json: { content: content }, status: :ok
    end

    def authorize_wallet
      authorize @wallet
    end

    def wallet_params
      params.require(:wallet).permit(
        :name,
        :address,
        :_blockchain
      )
    end

    def back_path
      account_path
    end
end
