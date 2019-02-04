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
      let!(:project) { create :project, account: issuer, coin_type: 'erc20' }
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
      let!(:project) { create :project, account: issuer, coin_type: 'qrc20', blockchain_network: 'qtum_testnet' }
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

  describe '#recipient_address' do
    let!(:recipient) { create(:account, ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec423') }
    let!(:project) { create :project, payment_type: 'project_token', coin_type: 'eth' }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, account: recipient, award_type: award_type }

    context 'on ethereum network' do
      it 'returns the recipient address' do
        expect(award.decorate.recipient_address).to eq('0xD8655aFe58B540D8372faaFe48441AeEc3bec423')
      end
    end

    context 'on bitcoin network' do
      before do
        award.account.bitcoin_wallet = 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps'
        award.project.coin_type = 'btc'
      end

      it 'returns the recipient address' do
        expect(award.decorate.recipient_address).to eq('msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps')
      end
    end

    context 'on cardano network' do
      before do
        award.account.cardano_wallet = 'Ae2tdPwUPEZ3uaf7wJVf7ces9aPrc6Cjiz5eG3gbbBeY3rBvUjyfKwEaswp'
        award.project.coin_type = 'ada'
      end

      it 'returns the recipient address' do
        expect(award.decorate.recipient_address).to eq('Ae2tdPwUPEZ3uaf7wJVf7ces9aPrc6Cjiz5eG3gbbBeY3rBvUjyfKwEaswp')
      end
    end

    context 'on qtum network' do
      before do
        award.account.qtum_wallet = 'qSf62RfH28cins3EyiL3BQrGmbqaJUHDfM'
        award.project.coin_type = 'qrc20'
      end

      it 'returns the recipient address' do
        expect(award.decorate.recipient_address).to eq('qSf62RfH28cins3EyiL3BQrGmbqaJUHDfM')
      end
    end

    context 'on eos network' do
      before do
        award.account.eos_wallet = 'aaatestnet11'
        award.project.coin_type = 'eos'
      end

      it 'returns the recipient address' do
        expect(award.decorate.recipient_address).to eq('aaatestnet11')
      end
    end
  end

  context 'recipient names' do
    let!(:recipient) { create(:account, first_name: 'Betty', last_name: 'Ross', ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec423') }
    let!(:project) { create :project, coin_type: 'erc20' }
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
    let!(:project) { create :project, id: 512, account: issuer, coin_type: 'erc20' }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, id: 521, award_type: award_type, issuer: issuer, account: recipient }

    it 'valid' do
      award.project.ethereum_contract_address = '0x8023214bf21b1467be550d9b889eca672355c005'
      expected = %({"id":521,"total_amount":"1337.0","issuer_address":"0xD8655aFe58B540D8372faaFe48441AeEc3bec453","amount_to_send":1337,"recipient_display_name":"Account ABC","account":{"id":529,"ethereum_wallet":"0xD8655aFe58B540D8372faaFe48441AeEc3bec488","qtum_wallet":null,"cardano_wallet":null,"bitcoin_wallet":null,"eos_wallet":null},"project":{"id":512,"ethereum_contract_address":"0x8023214bf21b1467be550d9b889eca672355c005","ethereum_network":null,"coin_type":"erc20","blockchain_network":null,"contract_address":null}})

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
    award.project.blockchain_network = 'qtum_testnet'
    expect(award.decorate.ethereum_transaction_explorer_url.include?('/tx/b808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb')).to be_truthy
  end

  it 'display unit_amount_pretty' do
    award = create :award, unit_amount: 2.34
    expect(award.decorate.unit_amount_pretty).to eq '2'
  end

  it 'display total_amount_pretty' do
    award = create :award, quantity: 2.5
    expect(award.decorate.total_amount_pretty).to eq '125'

    award = create :award, quantity: 25
    expect(award.decorate.total_amount_pretty).to eq '1,250'

    award.project.update decimal_places: 2
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
end
