# == Schema Information
#
# Table name: awards
#
#  authentication_id            :integer          not null
#  award_type_id                :integer          not null
#  created_at                   :datetime         not null
#  description                  :text
#  ethereum_transaction_address :string
#  id                           :integer          not null, primary key
#  issuer_id                    :integer          not null
#  proof_id                     :text
#  updated_at                   :datetime         not null
#

class Award < ActiveRecord::Base
  belongs_to :authentication
  belongs_to :issuer, class_name: Account
  belongs_to :award_type

  validates_presence_of :proof_id, :authentication, :award_type, :issuer

  before_validation :ensure_proof_id_exists
  after_commit :ethereum_token_issue, on: :create

  def ensure_proof_id_exists
    self.proof_id ||= SecureRandom.base58(44)
  end

  def ethereum_token_issue
    recipient_address = authentication.account.ethereum_wallet
    if recipient_address.present?
      EthereumTokenIssueJob.perform_async(self.id, award_type.project.id, {
        recipient: recipient_address,
        amount: award_type.amount
      })
    end
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

  def slack_team_id
    award_type.project.slack_team_id
  end
end
