# Auto Provisioning Flow – account created by CoMakery using ORE ID API.
# -- OreIdAccount created via ORE ID API --> created WalletProvision (OreIdAccount#state: pending, WalletProvision#stage: pending)
# -- account balance confirmed on chain --> (OreIdAccount#state: pending, WalletProvision#stage: initial_balance_confirmed)
# -- opt in tx created via ORE ID API --> (OreIdAccount#state: pending, WalletProvision#stage: opt_in_created)
# -- opt in tx confirmed on chain --> (OreIdAccount#state: pending, WalletProvision#stage: provisioned)
# -- CoMakery password reset api endpoint called --> (OreIdAccount#state: unclaimed, WalletProvision#stage: provisioned)
# -- passwordUpdatedAt on ORE ID API response has been changed --> (OreIdAccount#state: ok, WalletProvision#stage: provisioned)

class WalletProvision < ApplicationRecord
  belongs_to :wallet
  belongs_to :token

  enum stage: {
    pending: 0,
    initial_balance_confirmed: 1,
    opt_in_created: 2,
    provisioned: 3
  }
end
