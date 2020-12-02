class Auth::OreIdController < ApplicationController
  include OreIdCallbacks
  skip_after_action :verify_authorized

  # POST /auth/ore_id/new
  def new
    redirect_to auth_url
  end

  # DELETE /auth/ore_id/destroy
  def destroy
    current_ore_id_account.destroy!
    flash[:notice] = 'ORE ID Unlinked'
    redirect_to wallets_url
  end

  # GET /auth/ore_id/receive
  def receive
    verify_errorless or return
    verify_received_account or return

    if current_ore_id_account.update(account_name: params.require(:account), state: :ok)
      flash[:notice] = 'ORE ID Linked. Synchronising wallets...'
    else
      flash[:error] = current_ore_id_account.errors.full_messages.join(', ')
    end

    redirect_to received_state['redirect_back_to']
  end
end
