require 'slack'

class Account < ActiveRecord::Base
  has_many :account_roles, dependent: :destroy
  has_many :authentications, dependent: :destroy
  has_many :account_roles, dependent: :destroy
  has_many :roles, through: :account_roles

  attr_accessor :password, :password_required
  validates :password, length: {minimum: 8}, if: :password_required

  validates_presence_of :email, :name

  before_save :downcase_email

  def downcase_email
    self.email = email.try(:downcase)
  end

  def slack
    @slack ||= Swarmbot::Slack.new(slack_auth)
  end

  def slack_auth
    authentications.find_by(provider: "slack")
  end

  def send_reward_notifications(**args)
    slack.send_reward_notifications(**args)
  end
end
