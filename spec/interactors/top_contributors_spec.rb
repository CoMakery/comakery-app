require 'rails_helper'

describe TopContributors do
  before { travel_to(Date.new(2016, 6, 6)) }

  describe '#call' do
    let!(:sb_account_owner) { create(:sb_authentication).account }
    let!(:sb_auth1) { create(:sb_authentication, slack_user_name: 'sb1') }
    let!(:sb_auth2) { create(:sb_authentication, slack_user_name: 'sb2') }
    let!(:sb_auth3) { create(:sb_authentication, slack_user_name: 'sb3') }
    let!(:sb_auth4) { create(:sb_authentication, slack_user_name: 'sb4') }
    let!(:sb_auth5) { create(:sb_authentication, slack_user_name: 'sb5') }
    let!(:sb_auth6) { create(:sb_authentication, slack_user_name: 'sb6') }
    let!(:sb_project) { create(:sb_project, account: sb_account_owner) }

    let!(:small_award_type) { create(:award_type, project: sb_project, amount: 10) }
    let!(:medium_award_type) { create(:award_type, project: sb_project, amount: 500) }
    let!(:large_award_type) { create(:award_type, project: sb_project, amount: 1000) }
    let!(:extra_large_award_type) { create(:award_type, project: sb_project, amount: 2000) }

    before do
      create(:award, authentication: sb_auth1, award_type: medium_award_type, created_at: 5.days.ago)
      create(:award, authentication: sb_auth1, award_type: medium_award_type, created_at: 5.days.ago)
      create(:award, authentication: sb_auth1, award_type: large_award_type, created_at: 5.days.ago)
      create(:award, authentication: sb_auth3, award_type: extra_large_award_type, created_at: 4.days.ago)
      create(:award, authentication: sb_auth4, award_type: small_award_type, created_at: 3.days.ago)
      create(:award, authentication: sb_auth5, award_type: small_award_type, created_at: 2.days.ago)
    end

    describe 'with all award.quantity = 1' do
      before do
        create(:award, authentication: sb_auth2, award_type: large_award_type, created_at: 1.day.ago)
      end

      it "defaults to top 5 contributors ordered by
            total contribution/recency, excluding accounts without awards" do
        expect(described_class.call(projects: [sb_project])
            .contributors[sb_project].map(&:slack_user_name))
          .to eq(%w[sb3 sb1 sb2 sb5 sb4])
      end

      it 'can return a specified number of top contributors' do
        expect(described_class.call(projects: [sb_project], n: 3)
            .contributors[sb_project]
            .map(&:slack_user_name))
          .to eq(%w[sb3 sb1 sb2])
      end

      it %( can return a specified number of top contributors) do
        expect(described_class.call(projects: [sb_project], n: 3)
            .contributors[sb_project]
            .map { |auth| [auth.slack_user_name, auth.total_awarded.to_i, auth.last_awarded_at] })
          .to eq([['sb3', 2000, 4.days.ago], ['sb1', 2000, 5.days.ago], ['sb2', 1000, 1.day.ago]])
      end
    end

    describe 'with some award.quantity > 1' do
      before do
        create(:award, authentication: sb_auth2, award_type: large_award_type, quantity: 1.5, created_at: 1.day.ago)
      end

      it %(returns the most awarded contributors, ordered by total contribution/recency,
            excluding accounts without awards) do
        expect(described_class.call(projects: [sb_project], n: 3)
            .contributors[sb_project]
            .map { |auth| [auth.slack_user_name, auth.total_awarded.to_i, auth.last_awarded_at] })
          .to eq([['sb3', 2000, 4.days.ago], ['sb1', 2000, 5.days.ago], ['sb2', 1500, 1.day.ago]])
      end
    end
  end
end
