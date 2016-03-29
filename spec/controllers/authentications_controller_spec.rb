require 'rails_helper'

describe AuthenticationsController do
  let!(:project) { create(:sb_project) }
  let!(:auth) { create(:sb_authentication) }
  let!(:award_type) { create(:award_type, project: project) }
  let!(:award1) { create(:award, award_type: award_type, authentication: auth) }
  let!(:award2) { create(:award, award_type: award_type, authentication: auth) }

  before { login(auth.account) }

  describe "#show" do
    it "hella works" do
      get :show

      expect(response.status).to eq(200)
      expect(assigns[:current_account]).to eq(auth.account)
      expect(assigns[:authentication]).to eq(auth)
      expect(assigns[:awards]).to match_array([award1, award2])
    end
  end
end