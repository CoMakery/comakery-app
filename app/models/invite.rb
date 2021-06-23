class Invite < ApplicationRecord
  has_secure_token

  belongs_to :invitable, polymorphic: true
  has_one :account, dependent: :nullify

  validates :email, uniqueness: { case_sensitive: false, scope: %i[invitable_id invitable_type] }
  validates :account, presence: true, if: -> { accepted? }

  after_save :invite_accepted, if: -> { accepted? }

  delegate :invite_accepted, to: :invitable

  scope :pending, -> { where(accepted: false) }
end
