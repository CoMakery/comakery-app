class Account < ActiveRecord::Base
  has_many :account_roles, dependent: :destroy
  has_many :authentications, dependent: :destroy
  has_many :account_roles, dependent: :destroy
  has_many :roles, through: :account_roles

  attr_accessor :password, :password_required
  validates :password, length: {minimum: 8}, if: :password_required

  before_save :downcase_email

  def downcase_email
    self.email = email.try(:downcase)
  end
end
