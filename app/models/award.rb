class Award < ApplicationRecord
  include ::Rails.application.routes.url_helpers
  paginates_per 50

  include EthereumAddressable

  belongs_to :account, optional: true
  belongs_to :award_type
  belongs_to :issuer, class_name: 'Account'
  belongs_to :channel, optional: true
  has_one :team, through: :channel
  has_one :project, through: :award_type

  validates :proof_id, :award_type, :unit_amount, :total_amount, :quantity, presence: true
  validates :quantity, :total_amount, :unit_amount, numericality: { greater_than: 0 }

  validates :ethereum_transaction_address, ethereum_address: { type: :transaction, immutable: true } # see EthereumAddressable

  before_validation :ensure_proof_id_exists

  scope :confirmed, -> { where confirm_token: nil }

  def self.total_awarded
    sum(:total_amount)
  end

  def ensure_proof_id_exists
    self.proof_id ||= SecureRandom.base58(44) # 58^44 > 2^256
  end

  def ethereum_issue_ready?
    project.ethereum_enabled &&
      account&.ethereum_wallet.present? &&
      ethereum_transaction_address.blank?
  end

  def self_issued?
    account_id == issuer_id
  end

  def recipient_auth_team
    account.authentication_teams.find_by team_id: channel.team_id if channel
  end

  def notifications_message
    text = message_info
    text = "#{text} for \"#{description}\"" if description.present?

    text = if discord?
      "#{text} #{discord_message}"
    else
      "#{text} #{slack_message}"
    end

    text.strip!
    text.gsub!(/\s+/, ' ')
    text
  end

  def discord_message
    text = "on the #{project.title} project: #{project_url(project)}."

    if project.ethereum_enabled && recipient_address.blank?
      text = "#{text} Set up your account: #{account_url} to receive Ethereum tokens."
    end
    text
  end

  def slack_message
    text = "on the <#{project_url(project)}|#{project.title}> project."

    if project.ethereum_enabled && recipient_address.blank?
      text = "#{text} <#{account_url}|Set up your account> to receive Ethereum tokens."
    end
    text
  end

  def message_info
    if self_issued?
      "@#{issuer_user_name} self-issued"
    else
      "@#{issuer_user_name} sent @#{recipient_user_name} a #{total_amount} token #{award_type.name}"
    end
  end

  def send_confirm_email
    UserMailer.send_award_notifications(self).deliver_now unless discord? || confirmed?
  end

  def confirm!(account)
    update confirm_token: nil, account: account
  end

  def confirmed?
    confirm_token.blank?
  end

  def discord?
    team && team.discord?
  end
  delegate :image, to: :team, prefix: true, allow_nil: true

  def total_amount=(x)
    self[:total_amount] = x.round
  end
end
