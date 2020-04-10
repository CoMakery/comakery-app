class Api::AccountsController < Api::ApiController
  # NOTE: Disable controller until security issue is fixed
  before_action { head 503 }

  def create
    render(json: { failed: true }) && return if params[:public_address].blank?
    @account = Account.new(public_address: params[:public_address])
    @account.assign_attributes nonce: rand.to_s[2..6], email: "#{params[:public_address]}@comakery.com", network_id: params[:network_id], system_email: true
    @account.ethereum_wallet = @account.public_address
    if @account.valid?
      @account.email = nil
      @account.save(validate: false)
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
    @account = Account.find_by public_address: params[:public_address]
    if params[:public_address].blank? || @account.nil?
      render json: { success: false }
    else
      matched = @account.nonce == params[:nonce]
      if matched
        @account.nonce = rand.to_s[2..6]
        @account.save(validate: false)
        session[:account_id] = @account.id
      end
      render json: { success: matched }
    end
  end
end
