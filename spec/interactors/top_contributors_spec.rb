require 'rails_helper'

describe TopContributors do
  before { travel_to(Date.new(2016, 6, 6)) }

  describe '#call' do
    let!(:team) { create :team }
    let!(:sb_auth_owner) { create(:sb_authentication) }
    let!(:sb_auth1) { create(:sb_authentication) }
    let!(:sb_auth2) { create(:sb_authentication) }
    let!(:sb_auth3) { create(:sb_authentication) }
    let!(:sb_auth4) { create(:sb_authentication) }
    let!(:sb_auth5) { create(:sb_authentication) }
    let!(:sb_auth6) { create(:sb_authentication) }
    let!(:sb_account_owner) { sb_auth_owner.account }
    let!(:account1) { sb_auth1.account }
    let!(:account2) { sb_auth2.account }
    let!(:account3) { sb_auth3.account }
    let!(:account4) { sb_auth4.account }
    let!(:account5) { sb_auth5.account }
    let!(:account6) { sb_auth6.account }

    let!(:sb_project) { create(:sb_project, account: sb_account_owner) }
    let!(:award_type) { create(:award_type, project: sb_project) }

    before do
      team.build_authentication_team sb_auth_owner
      team.build_authentication_team sb_auth1
      team.build_authentication_team sb_auth2
      team.build_authentication_team sb_auth3
      team.build_authentication_team sb_auth4
      team.build_authentication_team sb_auth5
      team.build_authentication_team sb_auth6

      create(:award, account: account1, award_type: award_type, amount: 500, created_at: 5.days.ago)
      create(:award, account: account1, award_type: award_type, amount: 500, created_at: 5.days.ago)
      create(:award, account: account1, award_type: award_type, amount: 1000, created_at: 5.days.ago)
      create(:award, account: account3, award_type: award_type, amount: 2000, created_at: 4.days.ago)
      create(:award, account: account4, award_type: award_type, amount: 10, created_at: 3.days.ago)
      create(:award, account: account5, award_type: award_type, amount: 10, created_at: 2.days.ago)
    end

    describe 'with all award.quantity = 1' do
      before do
        create(:award, account: account2, award_type: award_type, amount: 1000, created_at: 1.day.ago)
      end

      it "defaults to top 5 contributors ordered by
            total contribution/recency, excluding accounts without awards" do
        expect(described_class.call(projects: [sb_project])
            .contributors[sb_project].map { |a| a.decorate.name })
          .to eq([account3.decorate.name, account1.decorate.name, account2.decorate.name, account5.decorate.name, account4.decorate.name])
      end
    end

    describe 'with some award.quantity > 1' do
      before do
        create(:award, account: account2, award_type: award_type, amount: 1000, quantity: 1.5, created_at: 1.day.ago)
      end

      it %(returns the most awarded contributors, ordered by total contribution/recency,
            excluding accounts without awards) do
        expect(described_class.call(projects: [sb_project])
            .contributors[sb_project]
            .map { |account| [account.decorate.name, account.total_awarded.to_i] })
          .to eq([[account3.decorate.name, 2000], [account1.decorate.name, 2000], [account2.decorate.name, 1500], [account5.decorate.name, 10],
                  [account4.decorate.name, 10]])
      end
    end
  end
end
