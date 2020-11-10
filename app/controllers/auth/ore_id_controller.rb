class Auth::OreIdController < ApplicationController
  skip_after_action :verify_authorized

  # GET /auth/ore_id/new
  def new
    redirect_to auth_url
  end

  # GET /auth/ore_id/receive
  def receive
    head 401 unless current_account.id == received_state['account_id']

    if current_ore_id_account.update(account_name: params.require[:account_name], state: :ok)
      redirect_to received_state['redirect_back_to'], notice: 'Signed in with ORE ID'
    else
      flash[:error] = current_ore_id_account.errors.full_messages.join(', ')
      redirect_to received_state['redirect_back_to']
    end
  end

  private

    def current_ore_id_account
      @current_ore_id_account ||= (current_account.ore_id_account || current_account.create_ore_id_account(state: :pending_manual))
    end

    def auth_url
      @auth_url ||= current_ore_id_account.service.authorization_url(auth_ore_id_receive_url, state)
    end

    def crypt
      @crypt ||= ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
    end

    def state
      @state ||= crypt.encrypt_and_sign({
        account_id: current_account.id,
        redirect_back_to: params.require[:redirect_back_to]
      }.to_json)
    end

    def received_state
      @received_state ||= JSON.parse(crypt.decrypt_and_verify(params.require[:state]))
    end
end
