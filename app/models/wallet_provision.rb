# Auto Provisioning Flow – account created by CoMakery using ORE ID API.
# -- OreIdAccount created via ORE ID API --> created WalletProvision (OreIdAccount#state: pending, WalletProvision#state: pending)
# -- account balance confirmed on chain --> (OreIdAccount#state: pending, WalletProvision#state: initial_balance_confirmed)
# -- opt in tx created via ORE ID API --> (OreIdAccount#state: pending, WalletProvision#state: opt_in_created)
# -- opt in tx confirmed on chain --> (OreIdAccount#state: pending, WalletProvision#state: provisioned)
# -- CoMakery password reset api endpoint called --> (OreIdAccount#state: unclaimed, WalletProvision#state: provisioned)
# -- passwordUpdatedAt on ORE ID API response has been changed --> (OreIdAccount#state: ok, WalletProvision#state: provisioned)

class WalletProvision < ApplicationRecord
  class WalletProvision::ProvisioningError < StandardError; end
  include Synchronisable

  belongs_to :wallet
  belongs_to :token
  has_one :ore_id_account, through: :wallet

  after_create :schedule_balance_sync
  after_update :schedule_create_opt_in_tx, if: :saved_change_to_state? && :initial_balance_confirmed?
  after_update :schedule_opt_in_tx_sync, if: :saved_change_to_state? && :opt_in_created?

  enum state: {
    pending: 0,
    initial_balance_confirmed: 1,
    opt_in_created: 2,
    provisioned: 3
  }

  def sync_balance
    if wallet.coin_balance&.value&.positive?
      initial_balance_confirmed!
    else
      raise WalletProvision::ProvisioningError, 'Balance is not ready'
    end
  end

  def create_opt_in_tx
    transaction do
      opt_in = TokenOptIn.find_or_create_by(wallet: wallet, token: token)
      opt_in.pending!

      blockchain_transaction = BlockchainTransactionOptIn.create!(blockchain_transactable: opt_in)
      ore_id_account.service.create_tx(blockchain_transaction)

      opt_in_created!
    end
  end

  def sync_opt_in_tx
    if wallet.token_opt_ins.all?(&:opted_in?)
      provisioned!
    else
      raise WalletProvision::ProvisioningError, 'OptIn tx is not ready'
    end
  end

  def schedule_balance_sync
    OreIdWalletBalanceSyncJob.perform_later(self)
  end

  def schedule_create_opt_in_tx
    OreIdWalletOptInTxCreateJob.perform_later(self)
  end

  def schedule_opt_in_tx_sync
    OreIdWalletOptInTxSyncJob.perform_later(self)
  end
end
