class ApiOreIdWalletRecovery < ApplicationRecord
  belongs_to :api_request_log

  validates :api_request_log_id, uniqueness: true
end
