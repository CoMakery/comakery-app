class AccountTokenRecord < ApplicationRecord
  belongs_to :account
  belongs_to :token
  belongs_to :reg_group, optional: true

  validates_with ComakeryTokenValidator
  validates :account, uniqueness: { scope: :token_id }

  before_save :touch_account

  private

  def touch_account
    account.touch # rubocop:disable Rails/SkipsModelValidations
  end
end
