class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[show edit update destroy]
  after_action :authorize_wallet, only: %i[new create show edit update destroy]
  helper_method :back_path

  # GET /wallets
  def index
    @wallets = policy_scope(Wallet).order(:_blockchain)
  end

  # GET /wallets/1
  def show; end

  # GET /wallets/new
  def new
    @wallet = policy_scope(Wallet).new
  end

  # GET /wallets/1/edit
  def edit; end

  # POST /wallets
  def create
    @wallet = policy_scope(Wallet).new(wallet_params)

    respond_to do |format|
      if @wallet.save
        format.html { redirect_to wallets_url, notice: 'Wallet added' }
      else
        flash.now[:error] = @wallet.errors.full_messages.join(', ')
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /wallets/1
  def update
    respond_to do |format|
      if @wallet.update(wallet_params)
        format.html { redirect_to wallets_url, notice: 'Wallet updated' }
      else
        flash.now[:error] = @wallet.errors.full_messages.join(', ')
        format.html { render :edit }
      end
    end
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

    def set_wallet
      @wallet = policy_scope(Wallet).find(params[:id])
    end

    def authorize_wallet
      authorize @wallet
    end

    def wallet_params
      params.require(:wallet).permit(
        :address,
        :_blockchain
      )
    end

    def back_path
      account_path
    end
end
