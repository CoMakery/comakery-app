class AccountTokenRecord < ApplicationRecord
  belongs_to :account
  belongs_to :token
  belongs_to :reg_group, optional: true

  after_initialize :set_defaults

  validates_with ComakeryTokenValidator
  validates :account, uniqueness: { scope: :token_id }

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
    end

    def touch_account
      account.touch # rubocop:disable Rails/SkipsModelValidations
    end
end
