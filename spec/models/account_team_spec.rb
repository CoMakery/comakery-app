require 'rails_helper'

RSpec.describe AccountTeam, type: :model do
  describe 'validations' do
    it 'requires things be present' do
      errors = described_class.new.tap(&:valid?).errors.full_messages
      expect(errors.sort).to eq([
                                  "Account can't be blank",
                                  "Team can't be blank"
                                ])
    end
  end

  describe 'has many projects' do
    let!(:account){create :account}
    let!(:project){create :project, account: account}
    let!(:team) {create :team}

    it 'return projects' do
      team.accounts << account
      account_team = account.account_teams.last
      expect(account_team.projects).to eq [project]
    end
  end
end
