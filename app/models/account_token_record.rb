class AccountTokenRecord < ApplicationRecord
  belongs_to :account
  belongs_to :token
  belongs_to :reg_group, optional: true

  validates_with ComakeryTokenValidator
  validates :account, uniqueness: { scope: :token_id }
end
