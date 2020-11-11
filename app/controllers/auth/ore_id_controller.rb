class Auth::OreIdController < ApplicationController
  include OreIdCallbacks
  skip_after_action :verify_authorized

  # GET /auth/ore_id/new
  def new
    redirect_to auth_url
  end

  # GET /auth/ore_id/receive
  def receive
    head 401 unless current_account.id == received_state['account_id']

    if current_ore_id_account.update(account_name: params.require(:account), state: :ok)
      redirect_to received_state['redirect_back_to'], notice: 'Signed in with ORE ID'
    else
      flash[:error] = current_ore_id_account.errors.full_messages.join(', ')
      redirect_to received_state['redirect_back_to']
    end
  end
end
