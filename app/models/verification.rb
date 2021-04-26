class Verification < ApplicationRecord
  belongs_to :account
  belongs_to :provider, class_name: 'Account'

  validates :passed, inclusion: { in: [true, false], message: 'is not boolean' }
  validates :max_investment_usd, numericality: { greater_than: 0 }

  after_update_commit :broadcast_update_wl_account_wallet, if: -> { account.whitelabel? && saved_change_to_passed? }

  after_create :set_account_latest_verification

  enum verification_type: { "aml-kyc": 0, accreditation: 1, "valid-identity": 2 }

  def failed?
    !passed?
  end

  private

    def broadcast_update_wl_account_wallet
      account.wallets.each do |wallet|
        broadcast_replace_to 'wl_account_wallets',
                             target: "wl_#{account.managed_mission.id}_account_#{account.id}_wallet_#{wallet.id}",
                             partial: 'accounts/partials/index/wl_account_wallet',
                             locals: { mission: account.managed_mission, wl_account_wallet: wallet }
      end
    end

    def set_account_latest_verification
      account.update(latest_verification: self)
    end
end
