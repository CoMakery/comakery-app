require 'rails_helper'

describe AwardDecorator do
  let!(:team) { create :team }
  let!(:issuer) { create :account, first_name: 'johnny', last_name: 'johnny', ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec453' }
  let!(:authentication) { create :authentication, account: issuer }
  let!(:project) { create :project, account: issuer }
  let!(:award_type) { create :award_type, project: project }
  let!(:channel) { create :channel, project: project, team: team, channel_id: 'channel' }

  before do
    team.build_authentication_team authentication
  end

  describe '#issuer_display_name' do
    context 'on ethereum network' do
      let!(:issuer) { create :account, first_name: 'johnny', last_name: 'johnny', ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec453' }
      let!(:project) { create :project, account: issuer, token: create(:token, coin_type: 'erc20') }
      let!(:award_type) { create :award_type, project: project }
      let!(:award) { create :award, award_type: award_type, issuer: issuer }

      it 'returns the user name' do
        expect(award.decorate.issuer_display_name).to eq('johnny johnny')
      end

      it 'issuer_user_name' do
        expect(award.decorate.issuer_user_name).to eq 'johnny johnny'
      end

      it 'issuer_address' do
        expect(award.decorate.issuer_address).to eq '0xD8655aFe58B540D8372faaFe48441AeEc3bec453'
      end
    end

    context 'on qtum network' do
      let!(:issuer) { create :account, first_name: 'johnny', last_name: 'johnny', qtum_wallet: 'qSf61RfH28cins3EyiL3BQrGmbqaJUHDfM' }
      let!(:project) { create :project, account: issuer, token: create(:token, coin_type: 'qrc20', blockchain_network: 'qtum_testnet') }
      let!(:award_type) { create :award_type, project: project }
      let!(:award) { create :award, award_type: award_type, issuer: issuer }

      it 'returns the user name' do
        expect(award.decorate.issuer_display_name).to eq('johnny johnny')
      end

      it 'issuer_user_name' do
        expect(award.decorate.issuer_user_name).to eq 'johnny johnny'
      end

      it 'issuer_address' do
        expect(award.decorate.issuer_address).to eq 'qSf61RfH28cins3EyiL3BQrGmbqaJUHDfM'
      end
    end
  end

  context 'recipient names' do
    let!(:recipient) { create(:account, first_name: 'Betty', last_name: 'Ross', ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec423') }
    let!(:project) { create :project, token: create(:token, coin_type: 'erc20') }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, account: recipient, award_type: award_type }

    describe '#recipient_display_name' do
      it 'returns the full name' do
        expect(award.decorate.recipient_display_name).to eq('Betty Ross')
      end
    end

    describe '#recipient_user_name' do
      it 'returns the recipient name' do
        expect(award.decorate.recipient_user_name).to eq('Betty Ross')
      end
    end

    it 'returns the recipient address' do
      expect(award.decorate.recipient_address).to eq('0xD8655aFe58B540D8372faaFe48441AeEc3bec423')
    end
  end

  context 'json_for_sending_awards' do
    let!(:recipient) { create :account, id: 529, first_name: 'Account', last_name: 'ABC', ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec488' }
    let!(:issuer) { create :account, first_name: 'johnny', last_name: 'johnny', ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec453' }
    let!(:project) { create :project, id: 512, account: issuer, token: create(:token, coin_type: 'erc20') }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, id: 521, award_type: award_type, issuer: issuer, account: recipient }

    it 'valid' do
      award.project.token.ethereum_contract_address = '0x8023214bf21b1467be550d9b889eca672355c005'
      expected = %({"id":521,"total_amount":"50.0","issuer_address":"0xD8655aFe58B540D8372faaFe48441AeEc3bec453","amount_to_send":50,"recipient_display_name":"Account ABC","account":{"id":529,"ethereum_wallet":"0xD8655aFe58B540D8372faaFe48441AeEc3bec488","qtum_wallet":null,"cardano_wallet":null,"bitcoin_wallet":null,"eos_wallet":null,"tezos_wallet":null},"project":{"id":512},"award_type":{"id":#{award_type.id}},"token":{"id":#{project.token.id},"coin_type":"erc20","ethereum_network":null,"blockchain_network":null,"contract_address":null,"ethereum_contract_address":null}})
      expect(award.decorate.json_for_sending_awards).to eq(expected)
    end

    it 'invalid' do
      expect(award.decorate.json_for_sending_awards).not_to eq(award.decorate.to_json(only: %i[id total_amount], methods: [:issuer_address]))
    end
  end

  it 'return ethereum_transaction_address_short' do
    award = create :award, ethereum_transaction_address: '0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
    expect(award.decorate.ethereum_transaction_address_short).to eq '0xb808727d...'
  end

  it 'return ethereum_transaction_explorer_url' do
    award = create :award, ethereum_transaction_address: '0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
    expect(award.decorate.ethereum_transaction_explorer_url.include?('/tx/0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb')).to be_truthy
  end

  it 'return ethereum_transaction_explorer_url for qtum' do
    award = create :award, ethereum_transaction_address: 'b808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
    award.project.token.blockchain_network = 'qtum_testnet'
    expect(award.decorate.ethereum_transaction_explorer_url.include?('/tx/b808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb')).to be_truthy
  end

  it 'display amount_pretty' do
    award = create :award, amount: 2.34
    expect(award.decorate.amount_pretty).to eq '2'
  end

  it 'display total_amount_pretty' do
    award = create :award, quantity: 2.5
    expect(award.decorate.total_amount_pretty).to eq '125'

    award = create :award, quantity: 25
    expect(award.decorate.total_amount_pretty).to eq '1,250'

    award.token.update decimal_places: 2
    expect(award.decorate.total_amount_pretty).to eq '1,250.00'
  end

  it 'display part_of_email' do
    award = create :award, quantity: 2.5, email: 'test@test.st'
    expect(award.decorate.part_of_email).to eq 'test@...'
  end

  it '#communication_channel' do
    award = create :award, quantity: 2.5, email: 'test@test.st'
    expect(award.decorate.communication_channel).to eq 'Email'

    award = create :award, award_type: award_type, quantity: 1, channel: channel
    expect(award.decorate.communication_channel).to eq channel.name_with_provider
  end

  describe 'total_amount_wei' do
    let!(:amount) { 2 }
    let!(:award_18_decimals) { create(:award, status: :ready, amount: amount) }
    let!(:award_2_decimals) { create(:award, status: :ready, amount: amount) }
    let!(:award_0_decimals) { create(:award, status: :ready, amount: amount) }
    let!(:award_no_token) { create(:award, status: :ready, amount: amount) }

    before do
      award_18_decimals.project.token.update(decimal_places: 18)
      award_2_decimals.project.token.update(decimal_places: 2)
      award_0_decimals.project.token.update(decimal_places: 0)
      award_no_token.project.update(token: nil)
    end

    it 'returns total_amount in Wei based on token decimals' do
      expect(award_18_decimals.decorate.total_amount_wei).to eq(2000000000000000000)
      expect(award_2_decimals.decorate.total_amount_wei).to eq(200)
      expect(award_0_decimals.decorate.total_amount_wei).to eq(2)
      expect(award_no_token.decorate.total_amount_wei).to eq(2)
    end
  end

  describe 'transfer_button_text' do
    let!(:eth_award) { create(:award, status: :accepted, award_type: create(:award_type, project: create(:project, token: create(:token, ethereum_contract_address: '0x8023214bf21b1467be550d9b889eca672355c005', coin_type: :erc20)))) }
    let!(:mint_award) { create(:award, status: :accepted, source: :mint, award_type: create(:award_type, project: create(:project, token: create(:token, ethereum_contract_address: '0x8023214bf21b1467be550d9b889eca672355c005', coin_type: :erc20)))) }
    let!(:burn_award) { create(:award, status: :accepted, source: :burn, award_type: create(:award_type, project: create(:project, token: create(:token, ethereum_contract_address: '0x8023214bf21b1467be550d9b889eca672355c005', coin_type: :erc20)))) }

    it 'returns text based on award source' do
      expect(eth_award.decorate.transfer_button_text).to eq('Pay')
      expect(mint_award.decorate.transfer_button_text).to eq('Mint')
      expect(burn_award.decorate.transfer_button_text).to eq('Burn')
    end
  end

  describe 'pay_data' do
    let!(:eth_award) { create(:award, status: :accepted, award_type: create(:award_type, project: create(:project, token: create(:token, ethereum_contract_address: '0x8023214bf21b1467be550d9b889eca672355c005', coin_type: :erc20)))) }
    let!(:mint_award) { create(:award, status: :accepted, source: :mint, award_type: create(:award_type, project: create(:project, token: create(:token, ethereum_contract_address: '0x8023214bf21b1467be550d9b889eca672355c005', coin_type: :erc20)))) }
    let!(:burn_award) { create(:award, status: :accepted, source: :burn, award_type: create(:award_type, project: create(:project, token: create(:token, ethereum_contract_address: '0x8023214bf21b1467be550d9b889eca672355c005', coin_type: :erc20)))) }
    let!(:other_award) { create(:award) }

    it 'returns payment data for ethereum_controller.js' do
      data = eth_award.decorate.pay_data
      expect(data['controller']).to eq('ethereum')
      expect(data['target']).to eq('ethereum.button')
      expect(data['action']).to eq('click->ethereum#pay')
      expect(data['ethereum-id']).to eq(eth_award.id)
      expect(data['ethereum-payment-type']).to eq(eth_award.token.coin_type)
      expect(data['ethereum-address']).to eq(eth_award.account.ethereum_wallet)
      expect(data['ethereum-amount']).to eq(eth_award.decorate.total_amount_wei)
      expect(data['ethereum-contract-address']).to eq(eth_award.project.token&.ethereum_contract_address)
      expect(data['ethereum-contract-abi']).to eq(eth_award.project.token&.abi&.to_json)
      expect(data['ethereum-transactions-path']).to include(eth_award.project.id.to_s)
      expect(data['info']).not_to be_nil
    end

    it 'returns mint data for comakery-security-token_controller.js' do
      data = mint_award.decorate.pay_data
      expect(data['controller']).to eq('comakery-security-token')
      expect(data['target']).to eq('comakery-security-token.button')
      expect(data['action']).to eq('click->comakery-security-token#mint')
      expect(data['comakery-security-token-id']).to eq(mint_award.id)
      expect(data['comakery-security-token-payment-type']).to eq(mint_award.token.coin_type)
      expect(data['comakery-security-token-address']).to eq(mint_award.account.ethereum_wallet)
      expect(data['comakery-security-token-amount']).to eq(mint_award.decorate.total_amount_wei)
      expect(data['comakery-security-token-contract-address']).to eq(mint_award.project.token&.ethereum_contract_address)
      expect(data['comakery-security-token-contract-abi']).to eq(mint_award.project.token&.abi&.to_json)
      expect(data['comakery-security-token-transactions-path']).to include(mint_award.project.id.to_s)
      expect(data['info']).not_to be_nil
    end

    it 'returns burn data for comakery-security-token_controller.js' do
      data = burn_award.decorate.pay_data
      expect(data['controller']).to eq('comakery-security-token')
      expect(data['target']).to eq('comakery-security-token.button')
      expect(data['action']).to eq('click->comakery-security-token#burn')
      expect(data['comakery-security-token-id']).to eq(burn_award.id)
      expect(data['comakery-security-token-payment-type']).to eq(burn_award.token.coin_type)
      expect(data['comakery-security-token-address']).to eq(burn_award.account.ethereum_wallet)
      expect(data['comakery-security-token-amount']).to eq(burn_award.decorate.total_amount_wei)
      expect(data['comakery-security-token-contract-address']).to eq(burn_award.project.token&.ethereum_contract_address)
      expect(data['comakery-security-token-contract-abi']).to eq(burn_award.project.token&.abi&.to_json)
      expect(data['comakery-security-token-transactions-path']).to include(burn_award.project.id.to_s)
      expect(data['info']).not_to be_nil
    end

    it 'returns data for legacy payment logic' do
      data = other_award.decorate.pay_data
      expect(data[:id]).not_to be_nil
      expect(data[:info]).not_to be_nil
    end
  end

  describe 'transfer_button_state_class' do
    let!(:award_created_not_expired) { create(:blockchain_transaction, status: :created, created_at: 1.year.from_now).award }
    let!(:award_pending) { create(:blockchain_transaction, status: :pending).award }
    let!(:award_created_expired) { create(:blockchain_transaction, status: :created, created_at: 1.year.ago).award }
    let!(:award) { create(:award) }

    it 'returns css class for award with created blockchain_transaction' do
      expect(award_created_not_expired.decorate.transfer_button_state_class).to eq('in-progress--metamask')
    end

    it 'returns css class for award with pending blockchain_transaction' do
      expect(award_pending.decorate.transfer_button_state_class).to eq('in-progress--metamask in-progress--metamask__paid')
    end

    it 'returns nil for award with created and expired blockchain_transaction' do
      expect(award_created_expired.decorate.transfer_button_state_class).to be_nil
    end

    it 'returns nil for award without blockchain_transaction' do
      expect(award.decorate.transfer_button_state_class).to be_nil
    end
  end
end
