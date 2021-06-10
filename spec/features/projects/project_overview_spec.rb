require 'rails_helper'

describe 'project overview page' do
  let(:current_auth) { create(:sb_authentication) }
  let(:project) { create :project, account: current_auth.account, title: 'Test project', token: token }

  before { login(current_auth.account) }

  context 'with algorand security token' do
    let(:token) { create(:algo_sec_token) }

    specify 'show token details' do
      visit project_path(project)

      expect(page).to have_content('Test project')
      expect(page).to have_content('AlgorandTest') # blockchain name
      expect(page).to have_link('13258116', href: 'https://testnet.algoexplorer.io/application/13258116') # token address
    end
  end

  context 'with bitcoin token' do
    let(:token) { create(:token) }

    specify 'show token details' do
      visit project_path(project)

      expect(page).to have_content('Test project')
      expect(page).to have_content('Bitcoin') # blockchain name
      expect(page).to have_link('BTC', href: 'https://live.blockcypher.com/btc/') # token address
    end
  end

  context 'with erc20 token' do
    let(:token) { create(:erc20_token) }

    specify 'show token details' do
      visit project_path(project)

      expect(page).to have_content('Test project')
      expect(page).to have_content('EthereumRopsten') # blockchain name
      expect(page).to have_link('0xc77...cD5Ab', href: 'https://ropsten.etherscan.io/address/0xc778417E063141139Fce010982780140Aa0cD5Ab') # token address
    end
  end
end
