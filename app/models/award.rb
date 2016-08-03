class Award < ActiveRecord::Base
  belongs_to :authentication
  belongs_to :issuer, class_name: Account
  belongs_to :award_type

  validates_presence_of :proof_id, :authentication, :award_type, :issuer

  before_validation :ensure_proof_id_exists
  after_commit :ethereum_token_issue

  def ensure_proof_id_exists
    self.proof_id ||= SecureRandom.base58(44)  # 58^44 > 2^256
  end

  def ethereum_token_issue
    if ethereum_contract_and_account?
      EthereumTokenIssueJob.perform_async(self.id, award_type.project.id, {
        recipient: recipient_address,
        amount: award_type.amount,
        proofId: proof_id
      })
    end
  end

  def ethereum_contract_and_account?
    award_type&.project&.ethereum_enabled && recipient_address.present?
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

  private

  def recipient_address
    authentication&.account&.ethereum_wallet
  end

  def slack_team_id
    award_type.project.slack_team_id
  end
end
