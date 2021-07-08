require 'rails_helper'

RSpec.describe InvitesController, type: :controller do
  describe 'GET #show' do
    let(:invite) { FactoryBot.create :invite, force_email: true }

    subject { get :show, params: { id: invite.token } }

    context 'when invite token is not claimed with the url token' do
      subject { get :show, params: { id: invite.token.downcase } }

      before { subject }

      it { expect(session[:invite_id]).to eq(nil) }
    end

    context 'when invite is accepted' do
      let(:invite) { FactoryBot.create :invite, :accepted }

      it { is_expected.to redirect_to '/404.html' }
    end

    context 'when not logged in' do
      it { is_expected.to redirect_to new_account_path }

      specify do
        subject
        expect(session[:invite_id]).to eq(invite.id)
      end
    end

    context 'when logged in' do
      before do
        login(account)
      end

      context 'with not invited account' do
        let(:account) { create(:account) }

        it { is_expected.to redirect_to account_path }
      end

      context 'with invited account' do
        let(:account) { create(:account, email: invite.email) }

        it { is_expected.to redirect_to redirect_invite_path(invite) }

        specify do
          subject
          invite.reload

          expect(invite).to be_accepted
          expect(invite.invitable.account).to eq(account)
        end
      end
    end
  end

  describe 'GET #redirect' do
    let(:invite) { FactoryBot.create :invite, :accepted_with_forced_email }
    let(:account) { invite.account }

    subject { get :redirect, params: { id: invite.id } }

    before do
      login(account)
    end

    context 'not logged in' do
      before do
        logout
      end

      it { is_expected.to redirect_to new_account_path }
    end

    context 'when invite is not accepted' do
      let(:invite) { FactoryBot.create :invite }
      let(:account) { create(:account) }

      it { is_expected.to redirect_to '/404.html' }
    end

    context 'when account is not invited account' do
      let(:account) { create(:account) }

      it { is_expected.to redirect_to '/404.html' }
    end

    context 'when account is invited account' do
      it { is_expected.to redirect_to project_dashboard_accounts_path(invite.invitable.project) }

      specify do
        session[:invite_id] = 'dummy'
        subject

        expect(session[:invite_id]).to be_nil
      end
    end
  end
end
