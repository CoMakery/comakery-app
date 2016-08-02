class BetaSignup < ActiveRecord::Base
  validates_presence_of :email_address
  validates_format_of :email_address, with: /\A.*@.*\z/, if: -> { email_address.present? }
end
