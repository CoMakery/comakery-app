class AccountTokenRecord < ApplicationRecord
  belongs_to :account
  belongs_to :token
  belongs_to :reg_group

  after_initialize :set_defaults

  LOCKUP_UNTIL_MAX = Time.zone.at(2.pow(256) - 1)
  LOCKUP_UNTIL_MIN = Time.zone.at(0)
  BALANCE_MAX = 2.pow(256) - 1
  BALANCE_MIN = 0

  validates_with ComakeryTokenValidator
  validates :account, uniqueness: { scope: :token_id }
  validates :lockup_until, inclusion: { in: LOCKUP_UNTIL_MIN..LOCKUP_UNTIL_MAX }
  validates :balance, inclusion: { in: BALANCE_MIN..BALANCE_MAX }, allow_nil: true
  validates :max_balance, inclusion: { in: BALANCE_MIN..BALANCE_MAX }, allow_nil: true

  before_save :touch_account

  def lockup_until
    super && Time.zone.at(super)
  end

  def lockup_until=(time)
    super(time.to_i.to_d)
  end

  private

    def set_defaults
      self.lockup_until ||= Time.current
      self.reg_group ||= RegGroup.default_for(token)
    end

    def touch_account
      account.touch # rubocop:disable Rails/SkipsModelValidations
    end
end
