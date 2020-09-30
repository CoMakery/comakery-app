class Balance < ApplicationRecord
  belongs_to :wallet
  belongs_to :token

  validates :base_unit_value, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :wallet_id, uniqueness: { scope: :token_id }

  def value
    token.from_base_unit(base_unit_value)
  end
end
