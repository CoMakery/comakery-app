class Api::AccountsController < Api::ApiController
  def create
    render(json: { failed: true }) && return if params[:public_address].blank?
    @account = Account.find_or_initialize_by public_address: params[:public_address]
    @account.assign_attributes nonce: rand.to_s[2..6], email: "#{params[:public_address]}@comakery.com"
    if @account.save
      render json: { account: @account.as_json(only: %i[id public_address nonce]) }
    else
      render json: { failed: true }
    end
  end
end
