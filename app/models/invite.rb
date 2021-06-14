class Invite < ApplicationRecord
  has_secure_token

  belongs_to :invitable, polymorphic: true

  validates :email, uniqueness: { case_sensitive: false }

  scope :pending, -> { where(accepted: false) }
end
