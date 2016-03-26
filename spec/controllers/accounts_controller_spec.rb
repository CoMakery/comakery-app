require 'rails_helper'

describe AccountsController do
  let(:account) { create(:sb_account) }

  before { login(account) }

  describe "#update" do
    it "works" do
      expect do
        put :update, account: {ethereum_address: "foobar"}
        expect(response.status).to eq(302)
      end.to change { account.reload.ethereum_address }.from(nil).to("foobar")

      expect(response).to redirect_to account_url
      expect(flash[:notice]).to eq("Ethereum address updated")
    end
  end
end