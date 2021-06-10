class Invite < ApplicationRecord
  has_secure_token

  belongs_to :invitable, polymorphic: true

  scope :pending, -> { where(accepted: false) }
end
