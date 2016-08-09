require 'rails_helper'

describe Award do

  describe "associations" do
    it "has the expected associations" do
      Award.create!(
        authentication: create(:authentication),
        issuer: create(:account),
        award_type: create(:award_type),
        proof_id: 'xyz123'
      )
    end
  end

  describe "validations" do
    it "requires things be present" do
      expect(Award.new.tap{|award| award.valid? }.errors.full_messages).to match_array([
        "Authentication can't be blank",
        "Award type can't be blank",
        "Issuer can't be blank",
      ])
    end

    describe "#ethereum_transaction_address" do
      it "should validate with a valid ethereum transaction address" do
        expect(build(:award, ethereum_transaction_address: nil)).to be_valid
        expect(build(:award, ethereum_transaction_address: "0x#{'a'*64}")).to be_valid
        expect(build(:award, ethereum_transaction_address: "0x#{'A'*64}")).to be_valid
      end

      it "should not validate with an invalid ethereum transaction address" do
        expected_error_message = "Ethereum transaction address should start with '0x', followed by a 64 character ethereum address"
        expect(build(:award, ethereum_transaction_address: "foo").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:award, ethereum_transaction_address: "0x").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:award, ethereum_transaction_address: "0x#{'a'*63}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:award, ethereum_transaction_address: "0x#{'a'*65}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:award, ethereum_transaction_address: "0x#{'g'*64}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
      end
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
