require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'association' do
    let!(:account){create :account}
    let!(:team) {create :team}

    it 'has many account_teams' do
      team.accounts << account
      expect(team.account_teams.count).to eq 1
    end

    it 'has many accounts' do
      team.accounts << account
      expect(team.accounts).to eq [account]
    end
  end
end
