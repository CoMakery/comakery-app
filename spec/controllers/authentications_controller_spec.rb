require 'rails_helper'

describe AuthenticationsController do
  let!(:project) { create(:sb_project) }
  let!(:issuer_account) { create(:account) }
  let!(:issuer_auth) { create(:sb_authentication, account: issuer_account) }
  let!(:recipient_auth) { create(:sb_authentication) }
  let!(:award_type) { create(:award_type, project: project) }
  let!(:award1) { create(:award, award_type: award_type, account: recipient_auth.account) }
  let!(:award2) { create(:award, award_type: award_type, account: recipient_auth.account) }

  before { login(recipient_auth.account) }

  describe '#show' do
    it 'hella works' do
      get :show

      expect(response.status).to eq(200)
      expect(assigns[:current_account]).to eq(recipient_auth.account)
      expect(assigns[:authentication]).to eq(recipient_auth)
      expect(assigns[:awards]).to match_array([award1, award2])
    end
  end
end
