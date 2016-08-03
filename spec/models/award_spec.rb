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
  end

  describe "callbacks" do
    describe "after commit: ethereum_token_issue" do
      it "should trigger for new award" do
        award_type = create(:award_type, project: create(:project))
        award = build(:award, award_type: award_type)
        expect(award).to receive(:ethereum_token_issue)
        award.save!
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

  describe "#ethereum_token_issue" do
    let!(:award) { create :award, proof_id: proof_id, authentication: authentication, award_type: award_type }
    let!(:award_type) { create :award_type, project: project, amount: award_amount }
    let!(:proof_id) { 'xyz12345' }
    let!(:award_amount) { 111 }
    let!(:project) { create :project }
    let!(:authentication) { create :authentication, account: account }
    let!(:account) { create :account, ethereum_wallet: ethereum_address }
    let!(:ethereum_address) { '0x'+'1'*40 }

    it "should create a job" do
      expect(award).to receive(:ethereum_contract_and_account?) { true }
      expect(EthereumTokenIssueJob).to receive(:perform_async).with(
        award.id, project.id, {
          recipient: ethereum_address,
          amount: award_amount,
          proofId: proof_id
        }
      )
      award.ethereum_token_issue
    end
  end

  describe "#ethereum_contract_and_account?" do
    xit "test it"
  end

end
