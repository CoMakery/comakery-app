class Award < ActiveRecord::Base
  include EthereumAddressable

  belongs_to :authentication
  belongs_to :issuer, class_name: Account
  belongs_to :award_type

  validates_presence_of :proof_id, :authentication, :award_type, :issuer

  validates :ethereum_transaction_address, ethereum_address: {type: :transaction}  # see EthereumAddressable
  before_validation :ensure_proof_id_exists

  def ensure_proof_id_exists
    self.proof_id ||= SecureRandom.base58(44)  # 58^44 > 2^256
  end

  def ethereum_issue_ready?
    award_type.project.ethereum_enabled &&
      recipient_address.present? &&
      ethereum_transaction_address.blank?
  end

  def issuer_display_name
    issuer.authentications.find_by(slack_team_id: slack_team_id)&.display_name
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

  def issuer_slack_icon
    issuer.team_auth(slack_team_id).slack_icon
  end

  private

  def slack_team_id
    award_type.project.slack_team_id
  end
end
