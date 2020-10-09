require 'rails_helper'

RSpec.describe Dashboard::AccountsController, type: :controller do
  let(:project) { create(:project, visibility: :public_listed, token: create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten)) }
  let(:account) { create(:account_token_record, token: project.token, max_balance: 2) }

  describe 'GET #index' do
    context 'with comakery token' do
      it 'returns a success response' do
        get :index, params: { project_id: project.to_param }
        expect(response).to be_successful
      end

      it 'creates token records for accounts' do
        get :index, params: { project_id: project.to_param }
        expect(project.account.account_token_records.find_by(token: project.token)).not_to be_nil
      end
    end
  end
end
