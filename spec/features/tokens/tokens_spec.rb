require 'rails_helper'

describe 'tokens features', js: true do
  let!(:admin_account) { create :account, comakery_admin: true }
  let!(:cat_token) { create(:token, name: 'ERC') }
  let!(:dog_token) { create(:token, name: 'QRC') }
  let!(:yak_token) { create(:token, name: 'ETH') }

  before do
    login(admin_account)
  end

  scenario 'admin creates an ETH token' do
    visit '/tokens'
    first('.sidebar-item__bold').click
    expect(page).to have_content 'Create A New Token'

    select('eTH', from: 'token[_token_type]', visible: false)
    select('Ethereum', from: 'token[_blockchain]', visible: false)
    attach_file('token[logo_image]', Rails.root.join('spec', 'fixtures', '600.png'))

    click_on 'create & close'
    find :css, '.token-index', wait: 10

    expect(Token.last._token_type).to eq 'eth'
    expect(Token.last._blockchain).to eq 'ethereum'
  end

  scenario 'admin creates an ERC20 token' do
    visit '/tokens'
    first('.sidebar-item__bold').click
    expect(page).to have_content 'Create A New Token'

    select('eRC20', from: 'token[_token_type]', visible: false)
    select('Ethereum', from: 'token[_blockchain]', visible: false)
    fill_in('token[name]', with: 'erc20 test')
    attach_file('token[logo_image]', Rails.root.join('spec', 'fixtures', '600.png')) # rubocop:todo Rails/FilePath

    stub_web3_fetch
    fill_in('token[contract_address]', with: '0x6c6ee5e31d828de241282b9606c8e98ea48526e2')

    # TODO: we should come up with something better for feature testing react pages than creating a race condition
    sleep 1

    expect(find_field('token[symbol]').value).to eq 'HOT'
    expect(find_field('token[decimal_places]').value).to eq '32'

    click_on 'create & close'
    find :css, '.token-index', wait: 10

    expect(Token.last._token_type).to eq 'erc20'
    expect(Token.last._blockchain).to eq 'ethereum'
    expect(Token.last.name).to eq 'erc20 test'
    expect(Token.last.contract_address).to eq '0x6c6ee5e31d828de241282b9606c8e98ea48526e2'
    expect(Token.last.symbol).to eq 'HOT'
    expect(Token.last.decimal_places).to eq 32
  end

  scenario 'admin creates an QRC20 token' do
    visit '/tokens'
    first('.sidebar-item__bold').click
    expect(page).to have_content 'Create A New Token'

    select('qRC20', from: 'token[_token_type]', visible: false)
    select('Qtum Testnet', from: 'token[_blockchain]', visible: false)
    fill_in('token[name]', with: 'qrc20 test')
    attach_file('token[logo_image]', Rails.root.join('spec', 'fixtures', '600.png')) # rubocop:todo Rails/FilePath

    stub_qtum_fetch
    fill_in('token[contract_address]', with: '2c754a7b03927a5a30ca2e7c98a8fdfaf17d11fc')

    # TODO: we should come up with something better for feature testing react pages than creating a race condition
    sleep 1

    expect(find_field('token[symbol]').value).to eq 'BIG'
    expect(find_field('token[decimal_places]').value).to eq '0'

    click_on 'create & close'
    find :css, '.token-index', wait: 10

    expect(Token.last._token_type).to eq 'qrc20'
    expect(Token.last._blockchain).to eq 'qtum_test'
    expect(Token.last.name).to eq 'qrc20 test'
    expect(Token.last.contract_address).to eq '2c754a7b03927a5a30ca2e7c98a8fdfaf17d11fc'
    expect(Token.last.symbol).to eq 'BIG'
    expect(Token.last.decimal_places).to eq 0
  end

  scenario 'admin cancels creation of token' do
    visit '/tokens'
    first('.sidebar-item__bold').click
    expect(page).to have_content 'Create A New Token'

    click_on 'cancel'

    # TODO: we should come up with something better for feature testing react pages than creating a race condition
    sleep 1

    expect(page).to have_content 'Create a Token'
  end

  scenario 'admin views list of tokens and token details' do
    visit '/tokens'
    expect(page).to have_content 'Tokens'
    expect(page).to have_content 'Please select token:'
    expect(find_all('.token-index--sidebar--item').count).to eq 3

    find_all('.token-index--sidebar--item')[0].click
    expect(first('.token-index--view--info')).to have_content 'ERC'

    find_all('.token-index--sidebar--item')[1].click
    expect(first('.token-index--view--info')).to have_content 'QRC'

    find_all('.token-index--sidebar--item')[2].click
    expect(first('.token-index--view--info')).to have_content 'ETH'
  end

  scenario 'admin edits token details' do
    visit '/tokens'
    find_all('.token-index--sidebar--item')[2].click
    first('.token-index--view--link').click_link 'edit token'

    expect(page).to have_content 'Edit Token'
    expect(find_field('token[name]').value).to eq 'ETH'

<<<<<<< HEAD
    select('eTH', from: 'token[_token_type]', visible: false)
    select('Ethereum', from: 'token[_blockchain]', visible: false)
    attach_file('token[logo_image]', Rails.root.join('spec', 'fixtures', '600.png'))
=======
    select('eTH', from: 'token[coin_type]', visible: false)
    select('main Ethereum Network', from: 'token[ethereum_network]', visible: false)
    attach_file('token[logo_image]', Rails.root.join('spec', 'fixtures', '600.png')) # rubocop:todo Rails/FilePath
>>>>>>> acceptance

    click_on 'save & close'
    find :css, '.token-index', wait: 10

    expect(Token.last._token_type).to eq 'eth'
    expect(Token.last._blockchain).to eq 'ethereum'
  end
end
