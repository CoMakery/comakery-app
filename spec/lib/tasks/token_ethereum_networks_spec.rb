require 'rails_helper'

describe 'rake migration:update_token_ethereum_networks', type: :task do
  let!(:project) { create :project, token: create(:token, ethereum_contract_address: '0x' + 'a' * 40, symbol: 'TEST', decimal_places: 2) }
  let!(:project1) { create :project, token: create(:token, ethereum_contract_address: nil, symbol: 'TEST', decimal_places: 2) }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no subscribers' do
    expect { task.execute }.not_to raise_error
  end

  it 'migrate data' do
    task.execute
    expect(project.token.reload.ethereum_network).to eq 'main'
    expect(project1.token.reload.ethereum_network).to be_nil
  end
end
