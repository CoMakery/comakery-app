class Award < ActiveRecord::Base
  include EthereumAddressable

  belongs_to :authentication
  belongs_to :issuer, class_name: Account
  belongs_to :award_type
  delegate :project, to: :award_type

  validates_presence_of :proof_id, :authentication, :award_type, :issuer, :unit_amount, :total_amount, :quantity
  validates_numericality_of :quantity, :total_amount, :unit_amount, greater_than: 0

  validates :ethereum_transaction_address, ethereum_address: {type: :transaction, immutable: true}  # see EthereumAddressable

  before_validation :ensure_proof_id_exists

  def ensure_proof_id_exists
    self.proof_id ||= SecureRandom.base58(44)  # 58^44 > 2^256
  end

  def ethereum_issue_ready?
    project.ethereum_enabled &&
      recipient_address.present? &&
      ethereum_transaction_address.blank?
  end

  def self_issued?
    issuer_slack_auth&.slack_user_id == authentication&.slack_user_id
  end

  def recipient_display_name
    authentication&.display_name
  end

  def recipient_slack_user_name
    authentication&.slack_user_name
  end

  def recipient_address
    recipient_account&.ethereum_wallet
  end

  def recipient_account
    authentication&.account
  end

  def issuer_display_name
    issuer_slack_auth&.display_name
  end

  def issuer_slack_user_name
    issuer_slack_auth&.slack_user_name
  end

  def issuer_slack_icon
    issuer_slack_auth&.slack_icon
  end

  def issuer_slack_auth
    issuer.team_auth(slack_team_id)
  end

  def total_amount=(x)
    write_attribute(:total_amount, x.round)
  end

  private

  def slack_team_id
    project.slack_team_id
  end
end
