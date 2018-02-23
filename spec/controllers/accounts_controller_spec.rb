require 'rails_helper'

describe AccountsController do
  let(:authentication) { create(:sb_authentication) }
  let(:account) { authentication.account }
  let(:award1) { create(:award, authentication: authentication) }
  let(:award2) { create(:award, authentication: authentication) }

  describe '#update' do
    before { login(account) }
    it 'updates a valid ethereum address successfully' do
      expect(CreateEthereumAwards).to receive(:call).with(awards: array_including(award1, award2))
      expect do
        put :update, params: { account: { ethereum_wallet: "0x#{'a' * 40}" } }
        expect(response.status).to eq(302)
      end.to change { account.reload.ethereum_wallet }.from(nil).to("0x#{'a' * 40}")

      expect(response).to redirect_to account_url
      expect(flash[:notice]).to eq('Ethereum account updated. If this is an unused account the address will not be visible on the Ethereum blockchain until it is part of a transaction.')
    end

    it 'renders errors for an invalid ethereum address' do
      expect do
        put :update, params: { account: { ethereum_wallet: 'not a valid ethereum address' } }
        expect(response.status).to eq(200)
      end.not_to change { account.reload.ethereum_wallet }

      expect(flash[:error]).to eq("Ethereum wallet should start with '0x', followed by a 40 character ethereum address")
      expect(assigns[:current_account]).to be
    end
  end

  describe '#create' do
    it 'renders errors for invalid password' do
      expect do
        post :create, params: {
          account: {
            email: 'user@test.st',
            password: '1'
          }
        }
        expect(response.status).to eq(200)
      end.to_not change { Account.count }
      new_account = assigns[:account]
      expect(new_account.errors.full_messages.first).to eq "Password is too short (minimum is 8 characters)"
    end

    it 'renders errors if email is blank' do
      expect do
        post :create, params: {
          account: {
            email: '',
            password: '1234678'
          }
        }
        expect(response.status).to eq(200)
      end.to_not change { Account.count }
      new_account = assigns[:account]
      expect(new_account.errors.full_messages.first).to eq "Email can't be blank"
    end

    it 'sign up for new account' do
      expect do
        post :create, params: {
          account: {
            email: 'user@test.st',
            password: '12345678'
          }
        }
        expect(response.status).to eq(302)
        new_account = assigns[:account]
      end.to change { Account.count }.by(1)
      expect(response).to redirect_to root_path
    end

    it 'renders errors if email has already been taken' do
      Account.create(email: 'user@test.st', password: '12345678')
      expect do
        post :create, params: {
          account: {
            email: 'user@test.st',
            password: '12345678'
          }
        }
        expect(response.status).to eq(200)
      end.to_not change { Account.count }
      new_account = assigns[:account]
      expect(new_account.errors.full_messages.first).to eq "Email has already been taken"
    end
  end
end
