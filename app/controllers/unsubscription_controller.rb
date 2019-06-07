class UnsubscriptionController < ApplicationController
  before_action :verify_signature
  skip_before_action :require_login
  skip_after_action :verify_authorized

  def new
    @unsub = Unsubscription.new(email: params[:email])
    if @unsub.save
      render plain: 'Successfully Unsubscribed'
    else
      render plain: @unsub.errors&.full_messages&.join(', '), status: :unprocessable_entity
    end
  end

  private

    def verify_signature
      head :unauthorized unless helpers.signature_valid?(params[:email], params[:signature])
    end
end
