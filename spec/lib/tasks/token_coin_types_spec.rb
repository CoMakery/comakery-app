require 'rails_helper'

describe 'rake migration:update_token_coin_types', type: :task do
  let!(:project) { create :project, token: create(:token, contract_address: '0x' + 'a' * 40, symbol: 'TEST', decimal_places: 2, blockchain_network: 'ropsten') }
  let!(:project1) { create :project, token: create(:token, contract_address: nil) }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no subscribers' do
    expect { task.execute }.not_to raise_error
  end

  it 'migrate data' do
    task.execute
    expect(project.token.reload.coin_type).to eq 'erc20'
    expect(project.token.reload.contract_address).to eq '0x' + 'a' * 40
    expect(project.token.reload.blockchain_network).to eq 'ropsten'
    expect(project.token.reload.symbol).to eq 'TEST'
    expect(project.token.reload.decimal_places).to eq 2

    expect(project1.token.reload.coin_type).to be_nil
  end
end
