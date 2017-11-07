class BetaSignup < ApplicationRecord
  validates :email_address, presence: true
  validates :email_address, format: { with: /\A.*@.*\z/, if: -> { email_address.present? } }
end
