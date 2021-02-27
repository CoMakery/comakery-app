class ApiRequestLog < ApplicationRecord
  validates :ip, :body, presence: true
  validates :signature, presence: true, uniqueness: true

  has_one :api_ore_id_wallet_recovery, dependent: :destroy
end
