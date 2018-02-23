class Account < ApplicationRecord
  has_secure_password validations: false
  include EthereumAddressable

  has_many :account_roles, dependent: :destroy
  has_many :authentications, -> { order(updated_at: :desc) }, dependent: :destroy
  has_many :awards, through: :authentications, dependent: :destroy
  has_one :slack_auth, -> { where(provider: 'slack').order('updated_at desc').limit(1) }, class_name: 'Authentication'
  default_scope { includes(:slack_auth) }
  has_many :account_roles, dependent: :destroy
  has_many :roles, through: :account_roles

  validates :email, presence: true, uniqueness: true

  validates :ethereum_wallet, ethereum_address: { type: :account } # see EthereumAddressable

  before_save :downcase_email

  def team_auth(slack_team_id)
    authentications.find_by(slack_team_id: slack_team_id)
  end

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
