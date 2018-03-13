require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'association' do
    let!(:authentication) { create :authentication }
    let!(:team) { create :team }

    it 'has many authentication_teams' do
      team.build_authentication_team authentication
      expect(team.authentication_teams.count).to eq 1
    end

    it 'has many accounts' do
      team.build_authentication_team authentication
      expect(team.accounts).to eq [authentication.account]
    end
  end
end
