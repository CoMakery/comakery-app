class ApiOreIdWalletRecovery < ApplicationRecord
  TOKEN_EXPIRATION_TIME = 5.minutes

  belongs_to :api_request_log

  validates :api_request_log_id, uniqueness: true

  def token_expired?
    DateTime.current > api_request_log.created_at + TOKEN_EXPIRATION_TIME
  end
end
