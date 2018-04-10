require 'rails_helper'

RSpec.describe AuthenticationTeam, type: :model do
  describe 'validations' do
    it 'requires many attributes' do
      errors = described_class.new.tap(&:valid?).errors.full_messages
      expect(errors.sort).to eq([
                                  "Account can't be blank",
                                  "Authentication can't be blank",
                                  "Team can't be blank"
                                ])
    end
  end

  describe 'has many projects' do
    let!(:authentication) { create :authentication }
    let!(:project) { create :project, account: authentication.account }
    let!(:team) { create :team }

    it 'return projects' do
      team.build_authentication_team authentication
      authentication_team = team.authentication_teams.last
      expect(authentication_team.projects).to eq [project]
    end
  end
end
