require 'rails_helper'

describe AwardDecorator do
  describe '#issuer_display_name' do
    let!(:issuer) { create :account, first_name: 'johnny', last_name: 'johnny', ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec453' }
    let!(:project) { create :project, account: issuer }
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

  context 'recipient names' do
    let!(:recipient) { create(:account, first_name: 'Betty', last_name: 'Ross', ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec423') }
    let!(:project) { create :project }
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
    let!(:recipient) { create :account, id: 529, ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec488' }
    let!(:issuer) { create :account, first_name: 'johnny', last_name: 'johnny', ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec453' }
    let!(:project) { create :project, id: 512, account: issuer, ethereum_contract_address: '0x8023214bf21b1467be550d9b889eca672355c005' }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, id: 521, award_type: award_type, issuer: issuer, account: recipient }

    it 'valid' do
      expected = %({"id":521,"total_amount":1337,"issuer_address":"0xD8655aFe58B540D8372faaFe48441AeEc3bec453","account":{"id":529,"ethereum_wallet":"0xD8655aFe58B540D8372faaFe48441AeEc3bec488"},"project":{"id":512,"ethereum_contract_address":"0x8023214bf21b1467be550d9b889eca672355c005"}})
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

  it 'display unit_amount_pretty' do
    award = create :award, unit_amount: 2.34
    expect(award.decorate.unit_amount_pretty).to eq '2'
  end

  it 'display total_amount_pretty' do
    award = create :award, quantity: 2.5
    expect(award.decorate.total_amount_pretty).to eq '125'
  end

  it 'display part_of_email' do
    award = create :award, quantity: 2.5, email: 'test@test.st'
    expect(award.decorate.part_of_email).to eq 'test@...'
  end
end
