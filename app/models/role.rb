class Role < ApplicationRecord
  has_many :account_roles, dependent: :destroy
  has_many :accounts, through: :account_roles

  validates :key, uniqueness: true
  validates :name, :key, presence: true

  ADMIN_ROLE_KEY = 'admin'.freeze

  def self.admin
    find_by(key: ADMIN_ROLE_KEY)
  end

  def self.admin?(user)
    # load and iterate, instead of asking DB, so multiple calls are efficient
    user&.roles&.include?(admin)
  end
end
