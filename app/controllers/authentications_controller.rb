class AuthenticationsController < ApplicationController
  skip_after_action :verify_authorized, only: [:show]

  def show
    @current_user = current_user
    @authentication = @current_user.slack_auth
    @awards = @authentication.awards.includes(award_type: :project).decorate
  end

  def update
    # JS update stripe bank account after callback
    # should add a CRF token

    authorize current_account
    @current_auth = current_user.slack_auth
    @current_auth.update!(stripe_bank_account_params)
    render text: "ok"
  end

  private

  def stripe_bank_account_params
    params.permit([:bank_account_account_holder_type,
                   :bank_account_bank_name,
                   :bank_account_country,
                   :bank_account_currency,
                   :bank_account_id,
                   :bank_account_last4,
                   :bank_account_name,
                   :bank_account_object,
                   :bank_account_routing_number,
                   :bank_account_status,
                   :stripe_token_client_ip,
                   :stripe_token_created,
                   :stripe_token_id,
                   :stripe_token_type,
                   :stripe_token_livemode
                  ])
  end
end
