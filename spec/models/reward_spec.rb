require 'rails_helper'

describe Reward do
  describe "associations" do
    it "has stuff" do
      Reward.create!(account: create(:account), issuer: create(:account), reward_type: create(:reward_type))
    end
  end

  describe "validations" do
    it "requires things be present" do
      expect(Reward.new.tap{|r|r.valid?}.errors.full_messages.sort).to eq(["Account can't be blank",
                                                                           "Issuer can't be blank",
                                                                           "Reward type can't be blank",
                                                                          ])
    end
  end

  describe "#issuer_slack_user_name" do
    let!(:issuer) { create :account }
    let!(:authentication) { create :authentication, account: issuer, slack_team_id: 'reds', slack_user_name: 'johnny' }
    let!(:project) { create :project, slack_team_id: 'reds' }
    let!(:reward_type) { create :reward_type, project: project }
    let!(:reward) { create :reward, issuer: issuer, reward_type: reward_type }

    it "returns the user name" do
      expect(reward.issuer_slack_user_name).to eq('johnny')
    end
  end

  describe "#recipient_slack_user_name" do
    let!(:recipient) { create :account }
    let!(:authentication) { create :authentication, account: recipient, slack_team_id: 'reds', slack_user_name: 'betty' }
    let!(:project) { create :project, slack_team_id: 'reds' }
    let!(:reward_type) { create :reward_type, project: project }
    let!(:reward) { create :reward, account: recipient, reward_type: reward_type }

    it "returns the user name" do
      expect(reward.recipient_slack_user_name).to eq('betty')
    end
  end
end
