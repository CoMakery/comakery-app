require 'rails_helper'

describe 'preview award', js: true do
  let!(:account) { create(:account, email: 'hubert@example.com', first_name: 'Michael', last_name: 'Jackson') }
  let!(:small_award_type) { create(:award_type, project: project, name: 'Small', amount: 1000) }

  before do
    login(account)
  end

  context 'on ethereum network' do
    let!(:project) do
      stub_token_symbol
      create(:project, title: 'Project that needs awards', account: account, ethereum_enabled: true, ethereum_contract_address: '0x' + '2' * 40, revenue_sharing_end_date: Time.zone.now + 3.days, maximum_tokens: 10000000, maximum_royalties_per_month: 1000000, ethereum_network: 'ropsten', coin_type: 'erc20')
    end

    before do
      visit project_path(project)
    end

    it 'recipient has an ethereum account' do
      create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com', ethereum_wallet: '0x' + 'a' * 40)

      fill_in 'Email Address', with: 'bobjohnson@example.com'
      page.find('body').click
      sleep 2
      expect(page.find('.preview_award_div')).to have_content '1000.0 FCBB total to ' + '0x' + 'a' * 40
      expect(page.find('.button_submit img')[:alt]).to have_content 'Metamask2'

      click_button 'Send'
      expect(page).to have_content 'Successfully sent award to bobjohnson'
      expect(EthereumTokenIssueJob.jobs.length).to eq(0)
    end

    it 'recipient has not an ethereum account' do
      create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com', qtum_wallet: 'qHn7L75EdErRwrDcAxD3fgiCnb6pMDg6iR')

      fill_in 'Email Address', with: 'bobjohnson@example.com'
      page.find('body').click
      sleep 2
      expect(page.find('.preview_award_div')).to have_content '1000.0 FCBB'
    end
  end

  context 'on qtum network' do
    let!(:project) do
      create(:project, title: 'Project that needs awards', account: account, ethereum_enabled: true, contract_address: '2' * 40, maximum_tokens: 10000000, maximum_royalties_per_month: 1000000, token_symbol: 'BIG', decimal_places: 8, blockchain_network: 'qtum_testnet', coin_type: 'qrc20')
    end

    before do
      visit project_path(project)
    end

    it 'recipient has a qtum account' do
      create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com', qtum_wallet: 'qHn7L75EdErRwrDcAxD3fgiCnb6pMDg6iR')

      fill_in 'Email Address', with: 'bobjohnson@example.com'
      page.find('body').click
      sleep 2
      expect(page.find('.preview_award_div')).to have_content '1000.0 BIG total to qHn7L75EdErRwrDcAxD3fgiCnb6pMDg6iR'
      expect(page.find('.button_submit img')[:alt]).to have_content 'Qrypto'
      click_button 'Send'
      expect(page).to have_content 'Successfully sent award to bobjohnson'
    end

    it 'recipient has not a qtum account' do
      create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com', ethereum_wallet: '0x' + 'a' * 40)

      fill_in 'Email Address', with: 'bobjohnson@example.com'
      page.find('body').click
      sleep 2
      expect(page.find('.preview_award_div')).to have_content '1000.0 BIG'
    end
  end

  context 'on cardano network' do
    let!(:project) do
      create(:project, title: 'Project that needs awards', account: account, ethereum_enabled: true, contract_address: '2' * 40, maximum_tokens: 10000000, maximum_royalties_per_month: 1000000, token_symbol: 'BIG', decimal_places: 8, blockchain_network: 'cardano_testnet', coin_type: 'ada')
    end

    before do
      visit project_path(project)
    end

    it 'recipient has a cardano account' do
      create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com', cardano_wallet: 'Ae2tdPwUPEZ3uaf7wJVf7ces9aPrc6Cjiz5eG3gbbBeY3rBvUjyfKwEaswp')

      fill_in 'Email Address', with: 'bobjohnson@example.com'
      page.find('body').click
      sleep 2
      expect(page.find('.preview_award_div')).to have_content '1000.0 ADA total to Ae2tdPwUPEZ3uaf7wJVf7ces9aPrc6Cjiz5eG3gbbBeY3rBvUjyfKwEaswp'
      expect(page.find('.button_submit img')[:alt]).to have_content 'Trezor'
      click_button 'Send'
      expect(page).to have_content 'Successfully sent award to bobjohnson'
    end

    it 'recipient has not a cardano account' do
      create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com', ethereum_wallet: '0x' + 'a' * 40)

      fill_in 'Email Address', with: 'bobjohnson@example.com'
      page.find('body').click
      sleep 2
      expect(page.find('.preview_award_div')).to have_content '1000.0 ADA'
    end
  end

  context 'on eos network' do
    let!(:project) do
      create(:project, title: 'Project that needs awards', account: account, ethereum_enabled: true, contract_address: '2' * 40, maximum_tokens: 10000000, maximum_royalties_per_month: 1000000, token_symbol: 'BIG', decimal_places: 8, blockchain_network: 'eos_testnet', coin_type: 'eos')
    end

    before do
      visit project_path(project)
    end

    it 'recipient has a eos account' do
      create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com', eos_wallet: 'aaatestnet11')

      fill_in 'Email Address', with: 'bobjohnson@example.com'
      page.find('body').click
      sleep 2
      expect(page.find('.preview_award_div')).to have_content '1000.0 EOS total to aaatestnet11'
      expect(page.find('.button_submit img')[:alt]).to have_content 'Eos'
      click_button 'Send'
      expect(page).to have_content 'Successfully sent award to bobjohnson'
    end

    it 'recipient has not a eos account' do
      create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com', ethereum_wallet: '0x' + 'a' * 40)

      fill_in 'Email Address', with: 'bobjohnson@example.com'
      page.find('body').click
      sleep 2
      expect(page.find('.preview_award_div')).to have_content '1000.0 EOS'
    end
  end

  context 'on tezos network' do
    let!(:project) do
      create(:project, title: 'Project that needs awards', account: account, ethereum_enabled: true, contract_address: '2' * 40, maximum_tokens: 10000000, maximum_royalties_per_month: 1000000, token_symbol: 'BIG', decimal_places: 8, blockchain_network: 'tezos_mainnet', coin_type: 'xtz')
    end

    before do
      visit project_path(project)
    end

    it 'recipient has a tezos account' do
      create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com', tezos_wallet: 'tz1Zbe9hjjSnJN2U51E5W5fyRDqPCqWMCFN9')

      fill_in 'Email Address', with: 'bobjohnson@example.com'
      page.find('body').click
      sleep 6
      expect(page.find('.preview_award_div')).to have_content '1000.0 XTZ total to tz1Zbe9hjjSnJN2U51E5W5fyRDqPCqWMCFN9'
      expect(page.find('.button_submit img')[:alt]).to have_content 'Tezos'
      click_button 'Send'
      expect(page).to have_content 'Successfully sent award to bobjohnson'
    end

    it 'recipient has not a tezos account' do
      create(:account, nickname: 'bobjohnson', email: 'bobjohnson@example.com', ethereum_wallet: '0x' + 'a' * 40)

      fill_in 'Email Address', with: 'bobjohnson@example.com'
      page.find('body').click
      sleep 2
      expect(page.find('.preview_award_div')).to have_content '1000.0 XTZ'
    end
  end
end
