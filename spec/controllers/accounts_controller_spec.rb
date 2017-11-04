require 'rails_helper'

describe AccountsController do
  let(:authentication) { create(:sb_authentication) }
  let(:account) { authentication.account }
  let(:award1) { create(:award, authentication: authentication) }
  let(:award2) { create(:award, authentication: authentication) }

  before { login(account) }

  describe '#update' do
    it 'updates a valid ethereum address successfully' do
      expect(CreateEthereumAwards).to receive(:call).with(awards: array_including(award1, award2))
      expect do
        put :update, params: {account: { ethereum_wallet: "0x#{'a' * 40}" }}
        expect(response.status).to eq(302)
      end.to change { account.reload.ethereum_wallet }.from(nil).to("0x#{'a' * 40}")

      expect(response).to redirect_to account_url
      expect(flash[:notice]).to eq('Ethereum account updated. If this is an unused account the address will not be visible on the Ethereum blockchain until it is part of a transaction.')
    end

    it 'renders errors for an invalid ethereum address' do
      expect do
        put :update, params: {account: { ethereum_wallet: 'not a valid ethereum address' }}
        expect(response.status).to eq(200)
      end.not_to change { account.reload.ethereum_wallet }

      expect(flash[:error]).to eq("Ethereum wallet should start with '0x', followed by a 40 character ethereum address")
      expect(assigns[:current_account]).to be
    end
  end
end
