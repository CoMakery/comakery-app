class Account < ActiveRecord::Base
  has_many :account_roles
  has_many :authentications
  has_many :roles, through: :account_roles

  attr_accessor :password, :password_required

  before_save do
    self.email = email.try(:downcase)
  end

  validates :password, length: {minimum: 8}, if: :password_required
end
