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
#  updated_at                   :datetime         not null
#

class Award < ActiveRecord::Base
  belongs_to :authentication
  belongs_to :issuer, class_name: Account
  belongs_to :award_type

  validates_presence_of :authentication, :issuer, :award_type

  after_create :ethereum_token_transfer

  def ethereum_token_transfer
    contract_address = award_type.project.ethereum_contract_address
    recipient_address = authentication.account.ethereum_wallet

    if contract_address.present? && recipient_address.present?
      EthereumTokenTransferJob.perform_async(self.id, {
        contractAddress: contract_address,
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
