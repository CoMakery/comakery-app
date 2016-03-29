require 'rails_helper'

describe AccountsController do
  let(:account) { create(:sb_authentication).account }

  before { login(account) }

  describe "#update" do
    it "works" do
      expect do
        put :update, account: {ethereum_wallet: "0x#{'a'*40}"}
        expect(response.status).to eq(302)
      end.to change { account.reload.ethereum_wallet }.from(nil).to("0x#{'a'*40}")

      expect(response).to redirect_to account_url
      expect(flash[:notice]).to eq("Ethereum wallet updated. If this is an unused wallet the address will not be visible on the Ethereum blockchain until it is part of a transaction.")
    end

    it "renders errors" do
      expect do
        put :update, account: {ethereum_wallet: "too short and spaces"}
        expect(response.status).to eq(200)
      end.not_to change { account.reload.ethereum_wallet }

      expect(flash[:error]).to eq("Ethereum wallet should start with '0x' and be 42 alpha-numeric characters long total")
      expect(assigns[:current_account]).to be
    end
  end
end
