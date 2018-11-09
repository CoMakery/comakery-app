require 'rails_helper'

describe 'rake migration:update_project_coin_types', type: :task do
  let!(:project) { create :project, ethereum_contract_address: '0x' + 'a' * 40, token_symbol: 'TEST', decimal_places: 2, ethereum_network: 'ropsten' }
  let!(:project1) { create :project, ethereum_contract_address: nil }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no subscribers' do
    expect { task.execute }.not_to raise_error
  end

  it 'migrate data' do
    task.execute
    expect(project.reload.coin_type).to eq 'erc20'
    expect(project.reload.ethereum_contract_address).to eq '0x' + 'a' * 40
    expect(project.reload.ethereum_network).to eq 'ropsten'
    expect(project.reload.token_symbol).to eq 'TEST'
    expect(project.reload.decimal_places).to eq 2

    expect(project1.reload.coin_type).to be_nil
  end
end
