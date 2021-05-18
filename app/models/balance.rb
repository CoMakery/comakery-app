class Balance < ApplicationRecord
  belongs_to :wallet
  belongs_to :token

  has_many :awards, ->(b) { joins(:project).where("projects.token_id": b.token_id) }, through: :wallet

  validates :base_unit_value, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :base_unit_locked_value, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :base_unit_unlocked_value, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :wallet_id, uniqueness: { scope: :token_id }
  validates :token_id, inclusion: { in: ->(b) { Array(b.wallet&.tokens_of_the_blockchain&.pluck(:id)) } }

  scope :ready_for_balance_update, -> { where(token: Token.support_balance).where('balances.updated_at < ? or balances.updated_at = balances.created_at', 10.seconds.ago) }

  def value
    token.from_base_unit(base_unit_value)
  end

  def locked_value
    token.from_base_unit(base_unit_locked_value)
  end

  def unlocked_value
    token.from_base_unit(base_unit_unlocked_value)
  end

  def lockup_schedule_ids
    awards.paid.distinct.pluck(:lockup_schedule_id)
  end

  def blockchain_balance_base_unit_value
    @blockchain_balance_base_unit_value ||= token.blockchain_balance(wallet.address)
  end

  def blockchain_balance_base_unit_locked_value
    @blockchain_balance_base_unit_locked_value ||= if token._token_type_token_release_schedule?
      token.blockchain_locked_balance(wallet.address)
    else
      0
    end
  end

  def blockchain_balance_base_unit_unlocked_value
    @blockchain_balance_base_unit_unlocked_value ||= if token._token_type_token_release_schedule?
      token.blockchain_unlocked_balance(wallet.address)
    else
      blockchain_balance_base_unit_value
    end
  end

  def sync_with_blockchain!
    update!(
      base_unit_value: blockchain_balance_base_unit_value,
      base_unit_locked_value: blockchain_balance_base_unit_locked_value,
      base_unit_unlocked_value: blockchain_balance_base_unit_unlocked_value
    )
  end

  def sync_with_blockchain_later
    SyncBalanceJob.set(queue: :critical).perform_later(self)
  end

  # Do not update the balance if it was updated recently but should be updated for just created balance
  def ready_for_balance_update?
    token.supports_balance? && (updated_at < 10.seconds.ago || updated_at == created_at)
  end
end
