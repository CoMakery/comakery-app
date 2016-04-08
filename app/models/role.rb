# == Schema Information
#
# Table name: roles
#
#  created_at :datetime
#  id         :integer          not null, primary key
#  key        :string           not null
#  name       :string           not null
#  updated_at :datetime
#

class Role < ActiveRecord::Base
  has_many :account_roles, dependent: :destroy
  has_many :accounts, through: :account_roles

  validates :key, uniqueness: true
  validates :name, :key, presence: true

  ADMIN_ROLE_KEY = 'admin'

  def self.admin
    find_by(key: ADMIN_ROLE_KEY)
  end

  def self.admin?(user)
    # load and iterate, instead of asking DB, so multiple calls are efficient
    user && user.roles.include?(admin)
  end
end
