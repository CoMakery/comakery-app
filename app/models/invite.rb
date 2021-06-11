class Invite < ApplicationRecord
  # TODO: Clarify expiration time
  EXPIRATION_TIME = 7.days

  has_secure_token

  belongs_to :invitable, polymorphic: true

  validates :email, uniqueness: { case_sensitive: false }

  before_create :update_expires_at

  scope :pending, -> { where(accepted: false) }

  def update_expires_at
    self.expires_at = DateTime.current + EXPIRATION_TIME
  end

  def expired?
    DateTime.current > expires_at
  end
end
