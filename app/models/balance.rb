class Balance < ApplicationRecord
  belongs_to :wallet
  belongs_to :token

  validates :base_unit_value, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :wallet_id, uniqueness: { scope: :token_id }
  validates :token_id, inclusion: { in: ->(b) { Array(b.wallet&.tokens_of_the_blockchain&.pluck(:id)) } }

  scope :ready_for_balance_update, -> { where('balances.updated_at < ? or balances.updated_at = balances.created_at', 10.seconds.ago) }

  def value
    token.from_base_unit(base_unit_value)
  end

  def blockchain_balance_base_unit_value
    @blockchain_balance_base_unit_value ||= token.blockchain_balance(wallet.address)
  end

  def sync_with_blockchain!
    update(base_unit_value: blockchain_balance_base_unit_value)
  end

  def sync_with_blockchain_later
    SyncBalanceJob.set(queue: :critical).perform_later(self)
  end

  # Do not update the balance if it was updated recently but should be updated for just created balance
  def ready_for_balance_update?
    updated_at < 10.seconds.ago || updated_at == created_at
  end
end
