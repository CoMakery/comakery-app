require 'rails_helper'

describe AuthenticationPolicy do
  let!(:team) {create :team}
  let!(:authentication1) { create(:sb_authentication) }
  let!(:authentication2) { create(:sb_authentication) }
  let!(:authentication3) { create(:cc_authentication) }

  before do
    team.build_authentication_team authentication1
    team.build_authentication_team authentication2
  end

  describe AuthenticationPolicy::Scope do
    describe '#resolve' do
      it 'returns all authentications that have the same slack team id' do
        expect(AuthenticationPolicy::Scope.new(authentication1.account, team).resolve).to match_array([authentication1, authentication2])
      end
    end
  end
end
