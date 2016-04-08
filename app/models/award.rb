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
