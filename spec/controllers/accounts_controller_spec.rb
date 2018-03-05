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
      expect(flash[:notice]).to eq('Your account details have been updated.')
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

  describe '#new' do
    it 'redirect to signup page' do
      get :new
      expect(response.status).to eq 200
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
      end.not_to change { Account.count }
      new_account = assigns[:account]
      expect(new_account.errors.full_messages.first).to eq 'Password is too short (minimum is 8 characters)'
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
      end.not_to change { Account.count }
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
      end.not_to change { Account.count }
      new_account = assigns[:account]
      expect(new_account.errors.full_messages.first).to eq 'Email has already been taken'
    end
  end

  describe '#confirm' do
    let!(:new_account) { create(:account, email: 'user@test.st', email_confirm_token: '1234qwer') }

    it 'render errors for invalid confirmation token' do
      get :confirm, params: { token: 'invalid token' }
      expect(new_account.confirmed?).to be false
      expect(flash[:error]).to eq 'Invalid token'
    end

    it 'confirm user email with given token' do
      get :confirm, params: { token: '1234qwer' }
      expect(new_account.reload.confirmed?).to be true
      expect(flash[:notice]).to eq 'Success! Your email is confirmed.'
    end
  end

  describe '#get_awards' do
    let!(:issuer) { create(:account, email: 'issuer@example.com').tap { |a| create(:authentication, slack_team_id: 'foo', account: a, slack_user_id: 'issuer id') } }
    let!(:receiver) { create(:account, email: 'receiver@example.com').tap { |a| create(:authentication, slack_team_id: 'foo', account: a, slack_user_id: 'issuer id') } }
    let!(:receiver1) { create(:account, email: 'receiver1@example.com') }

    let!(:receiver_authentication) { create(:authentication, slack_first_name: 'Rece', slack_last_name: 'Iver', slack_team_id: 'foo', slack_user_name: 'receiver', slack_user_id: 'receiver id', account: create(:account, email: 'receiver2@example.com')) }

    let!(:project) { create(:project, owner_account: issuer, slack_team_id: 'foo', public: false, maximum_tokens: 100_000_000) }
    let!(:award_type) { create(:award_type, project: project) }
    let!(:award_link) { create(:award_link, quantity: 1, award_type: award_type, token: '12345') }

    context "don't have slack" do
      before do
        login(receiver1)
      end

      it 'render error for invalid token' do
        expect do
          get :receive_award, params: { token: 'invalid token' }
        end.not_to change { receiver1.awards.count }
        expect(flash[:error]).to eq 'Invalid award token.'
        expect(response).to redirect_to(root_path)
      end

      it 'render error for account without slack' do
        receiver1.authentications.destroy_all
        allow(AwardLink).to receive(:find_by).and_return(award_link)
        allow(award_link).to receive(:owner).and_return(issuer)
        allow(issuer).to receive(:send_award_notifications)
        expect do
          get :receive_award, params: { token: '12345' }
        end.not_to change { receiver1.awards.count }
        expect(flash[:error]).to eq 'missing slack_user_id'
        expect(response).to redirect_to(root_path)
      end
    end

    context 'have slact authentication' do
      before do
        login(receiver)
      end

      it 'render error for invalid token' do
        expect do
          get :receive_award, params: { token: 'invalid token' }
        end.not_to change { receiver.awards.count }
        expect(flash[:error]).to eq 'Invalid award token.'
        expect(response).to redirect_to(root_path)
      end

      it 'create award for account' do
        allow(AwardLink).to receive(:find_by).and_return(award_link)
        allow(award_link).to receive(:owner).and_return(issuer)
        allow(issuer).to receive(:send_award_notifications)
        expect do
          get :receive_award, params: { token: '12345' }
        end.to change { receiver.awards.count }.by(1)
        expect(award_link.reload.display_status).to eq 'received'
        expect(flash[:notice]).to eq 'Successfully receive award to your account.'
        expect(response).to redirect_to(account_path)
      end
    end
  end
end
