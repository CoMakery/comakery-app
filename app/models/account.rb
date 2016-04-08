# == Schema Information
#
# Table name: accounts
#
#  created_at                      :datetime
#  crypted_password                :string
#  email                           :string
#  ethereum_wallet                 :string
#  failed_logins_count             :integer          default("0")
#  id                              :integer          not null, primary key
#  last_activity_at                :datetime
#  last_login_at                   :datetime
#  last_login_from_ip_address      :string
#  last_logout_at                  :datetime
#  lock_expires_at                 :datetime
#  remember_me_token               :string
#  remember_me_token_expires_at    :datetime
#  reset_password_email_sent_at    :datetime
#  reset_password_token            :string
#  reset_password_token_expires_at :datetime
#  salt                            :string
#  unlock_token                    :string
#  updated_at                      :datetime
#
# Indexes
#
#  index_accounts_on_email                                (email) UNIQUE
#  index_accounts_on_last_logout_at_and_last_activity_at  (last_logout_at,last_activity_at)
#  index_accounts_on_remember_me_token                    (remember_me_token)
#  index_accounts_on_reset_password_token                 (reset_password_token)
#

class Account < ActiveRecord::Base
  has_many :account_roles, dependent: :destroy
  has_many :authentications, -> { order(updated_at: :desc) }, dependent: :destroy
  has_one :slack_auth, -> { where(provider: "slack").order("updated_at desc").limit(1) }, class_name: Authentication
  default_scope { includes(:slack_auth) }
  has_many :account_roles, dependent: :destroy
  has_many :roles, through: :account_roles

  attr_accessor :password, :password_required
  validates :password, length: {minimum: 8}, if: :password_required

  validates_presence_of :email

  validates_format_of :ethereum_wallet, with: /\A0x[a-zA-Z0-9]{40}\z/, message: "should start with '0x' and be 42 alpha-numeric characters long total", if: ->(account) { account.ethereum_wallet.present? }

  before_save :downcase_email

  def downcase_email
    self.email = email.try(:downcase)
  end

  def slack
    @slack ||= Comakery::Slack.get(slack_auth.slack_token)
  end

  def send_award_notifications(**args)
    slack.send_award_notifications(**args)
  end
end
