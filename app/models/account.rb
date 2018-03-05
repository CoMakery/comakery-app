class Account < ApplicationRecord
  has_secure_password validations: false
  attachment :image
  include EthereumAddressable

  has_many :account_roles, dependent: :destroy
  has_many :authentications, -> { order(updated_at: :desc) }, dependent: :destroy
  has_many :awards, source: :receiver, dependent: :destroy
  has_one :slack_auth, -> { where(provider: 'slack').order('updated_at desc').limit(1) }, class_name: 'Authentication'
  default_scope { includes(:slack_auth) }
  has_many :account_roles, dependent: :destroy
  has_many :roles, through: :account_roles

  validates :email, presence: true, uniqueness: true
  attr_accessor :password_required
  validates :password, length: { minimum: 8 }, if: :password_required

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

  def confirmed?
    email_confirm_token.nil?
  end

  def confirm!
    update email_confirm_token: nil
  end

  def name
    [first_name, last_name].reject(&:blank?).join(' ')
  end

  def send_reset_password_request
    update reset_password_token: SecureRandom.hex
    UserMailer.reset_password(self).deliver_now
  end
end
