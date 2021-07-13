require 'rails_helper'

RSpec.describe Projects::Transfers::SettingsController, type: :controller do
  let(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }

  let(:project) { transfer.project }

  let(:account) { project.account }

  let(:params) do
    {
      project_id: project.id,
      transfer_id: transfer.id
    }
  end

  describe 'GET #show' do
    context 'when user is unauthorized' do
      get :show, params: params

      it { expect(response).to have_http_status(:not_found) }
    end

    context 'when user is authorized' do
      before { login(account) }

      it 'renders a successful response' do
        get :show, params: params

        expect(response).to have_http_status(:success)

        expect(assigns[:transfer]).to eq(transfer)

        expect(assigns[:project]).to eq(project)
      end
    end
  end
end
