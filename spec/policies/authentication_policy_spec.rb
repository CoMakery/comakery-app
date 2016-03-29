require 'rails_helper'

describe AuthenticationPolicy do
  let!(:authentication1) { create(:sb_authentication, slack_user_name: "authentication1") }
  let!(:authentication2) { create(:sb_authentication, slack_user_name: "authentication2") }
  let!(:authentication3) { create(:cc_authentication, slack_user_name: "authentication3") }

  describe AuthenticationPolicy::Scope do
    describe "#resolve" do
      it "returns all authentications that have the same slack team id" do
        expect(AuthenticationPolicy::Scope.new(authentication1.account, Authentication).resolve.map(&:slack_user_name)).to match_array(%w(authentication1 authentication2))
      end
    end
  end
end