require 'rails_helper'

describe Award do
  describe "associations" do
    it "has stuff" do
      Award.create!(authentication: create(:authentication), issuer: create(:account), award_type: create(:award_type))
    end
  end

  describe "validations" do
    it "requires things be present" do
      expect(Award.new.tap{|r|r.valid?}.errors.full_messages.sort).to eq(["Authentication can't be blank",
                                                                           "Award type can't be blank",
                                                                           "Issuer can't be blank",
                                                                          ])
    end
  end

  describe "#issuer_slack_user_name" do
    let!(:issuer) { create :account }
    let!(:project) { create :project, slack_team_id: 'reds' }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, issuer: issuer, award_type: award_type }

    it "returns the user name" do
      create(:authentication, account: issuer, slack_team_id: 'reds', slack_user_name: 'johnny', slack_first_name: nil, slack_last_name: nil)
      expect(award.issuer_slack_user_name).to eq('@johnny')
    end

    it "doesn't explode if auth is missing" do
      expect(award.issuer_slack_user_name).to be_nil
    end
  end

  describe "#recipient_slack_user_name" do
    let!(:recipient) { create(:authentication, slack_team_id: 'reds', slack_first_name: "Betty", slack_last_name: "Ross", slack_user_name: 'betty') }
    let!(:project) { create :project, slack_team_id: 'reds' }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, authentication: recipient, award_type: award_type }

    it "returns the user name" do
      expect(award.recipient_slack_user_name).to eq('Betty Ross')
    end
  end
end
