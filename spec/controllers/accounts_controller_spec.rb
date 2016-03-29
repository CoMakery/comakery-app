require 'rails_helper'

describe AccountsController do
  let(:account) { create(:sb_authentication).account }

  before { login(account) }

  describe "#update" do
    it "works" do
      expect do
        put :update, account: {ethereum_address: "0x#{'a'*40}"}
        expect(response.status).to eq(302)
      end.to change { account.reload.ethereum_address }.from(nil).to("0x#{'a'*40}")

      expect(response).to redirect_to account_url
      expect(flash[:notice]).to eq("Ethereum address updated")
    end

    it "renders errors" do
      expect do
        put :update, account: {ethereum_address: "too short and spaces"}
        expect(response.status).to eq(200)
      end.not_to change { account.reload.ethereum_address }

      expect(flash[:error]).to eq("Ethereum address should start with '0x' and be 42 alpha-numeric characters long total")
      expect(assigns[:current_account]).to be
    end
  end
end
