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

require 'rails_helper'

describe Award do
  before do
    allow(Comakery::Ethereum).to receive(:token_issue) { }
  end

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

  describe "#issuer_display_name" do
    let!(:issuer) { create :account }
    let!(:project) { create :project, slack_team_id: 'reds' }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, issuer: issuer, award_type: award_type }

    it "returns the user name" do
      create(:authentication, account: issuer, slack_team_id: 'reds', slack_user_name: 'johnny', slack_first_name: nil, slack_last_name: nil)
      expect(award.issuer_display_name).to eq('@johnny')
    end

    it "returns the auth for the correct team, even if older" do
      travel_to Date.new(2015)
      create(:authentication, account: issuer, slack_team_id: 'reds', slack_user_name: 'johnny-red', slack_first_name: nil, slack_last_name: nil)
      travel_to Date.new(2016)
      create(:authentication, account: issuer, slack_team_id: 'blues', slack_user_name: 'johnny-blue', slack_first_name: nil, slack_last_name: nil)
      expect(award.issuer_display_name).to eq('@johnny-red')
    end

    it "doesn't explode if auth is missing" do
      expect(award.issuer_display_name).to be_nil
    end
  end

  context "recipient names" do
    let!(:recipient) { create(:authentication, slack_team_id: 'reds', slack_first_name: "Betty", slack_last_name: "Ross", slack_user_name: 'betty') }
    let!(:project) { create :project, slack_team_id: 'reds' }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, authentication: recipient, award_type: award_type }

    describe "#recipient_display_name" do
      it "returns the full name" do
        expect(award.recipient_display_name).to eq('Betty Ross')
      end
    end

    describe "#recipient_slack_user_name" do
      it "returns the user name" do
        expect(award.recipient_slack_user_name).to eq('betty')
      end
    end
  end
end
