class Api::AccountsController < Api::ApiController
  def create
    render(json: { failed: true }) && return if params[:public_address].blank?
    @account = Account.new(public_address: params[:public_address])
    @account.assign_attributes nonce: rand.to_s[2..6], email: "#{params[:public_address]}@comakery.com", network_id: params[:network_id], system_email: true
    @account.ethereum_wallet = @account.public_address
    if @account.save
      render json: @account.as_json(only: %i[id public_address nonce ethereum_wallet])
    else
      render json: { failed: true }
    end
  end

  def find_by_public_address
    if params[:public_address].present? && (@account = Account.find_by public_address: params[:public_address])
      render json: @account.as_json(only: %i[id public_address nonce])
    else
      render json: {}
    end
  end

  def auth
    eth_util = EthereumUtilSchmoozer.new(Rails.root)
    @account = Account.find_by public_address: params[:public_address]
    if params[:public_address].blank? || @account.nil?
      render json: { success: false }
    else
      msg = "Comakery, I am signing my nonce: #{@account.nonce}"
      @matched = eth_util.verify_signature(params[:public_address], params[:signature], msg)
      if @matched
        @account.update!(nonce: rand.to_s[2..6])
        session[:account_id] = @account.id
      end
      render json: { success: @matched }
    end
  end
end
