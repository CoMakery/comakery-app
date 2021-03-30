class ApiOreIdWalletRecovery < ApplicationRecord
  TOKEN_EXPIRATION_TIME = 5.minutes

  belongs_to :api_request_log

  validates :api_request_log_id, uniqueness: true
  validate :request_expired?, on: :create, if: :api_request_log

  private

    def request_expired?
      errors.add(:api_request_log, 'is expired for recovery') if DateTime.current > api_request_log.created_at + TOKEN_EXPIRATION_TIME
    end
end
