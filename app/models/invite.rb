class Invite < ApplicationRecord
  TOKEN_LENGTH = 72

  has_secure_token

  belongs_to :invitable, polymorphic: true
  belongs_to :account, optional: true

  validates :email, uniqueness: { case_sensitive: false, scope: %i[invitable_id invitable_type] }
  validates :account, presence: true, if: -> { accepted? }
  validate :validate_account_email, if: -> { account.present? }

  after_save_commit :invite_accepted, if: -> { accepted? }

  delegate :invite_accepted, to: :invitable

  scope :pending, -> { where(accepted: false) }

  private

    def self.generate_unique_secure_token
      SecureRandom.base58(TOKEN_LENGTH)
    end

    def validate_account_email
      errors.add(:account, 'must have the same email') if force_email? && email != account.email
    end
end
