class Verification < ApplicationRecord
  belongs_to :account
  belongs_to :provider, class_name: 'Account'

  validates :passed, inclusion: { in: [true, false], message: 'is not boolean' }
  validates :max_investment_usd, numericality: { greater_than: 0 }

  after_create :set_account_latest_verification

  enum verification_type: { "aml-kyc": 0, accreditation: 1, "valid-identity": 2 }

  def failed?
    !passed?
  end

  private

    def set_account_latest_verification
      account.update(latest_verification: self)
    end
end
