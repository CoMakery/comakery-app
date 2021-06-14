require 'rails_helper'

describe AwardDecorator do
  let!(:team) { create :team }
  let!(:issuer) { create :account, first_name: 'johnny', last_name: 'johnny' }
  let!(:recipient) { create :account, first_name: 'Betty', last_name: 'Ross' }
  let!(:authentication) { create :authentication, account: issuer }
  let!(:project) { create :project, account: issuer, token: create(:token, _token_type: 'eth', _blockchain: :ethereum_ropsten) }
  let!(:wallet_issuer) { create :wallet, account: issuer, address: '0xD8655aFe58B540D8372faaFe48441AeEc3bec453', _blockchain: project.token._blockchain }
  let!(:wallet_recipient) { create :wallet, account: recipient, address: '0xD8655aFe58B540D8372faaFe48441AeEc3bec423', _blockchain: project.token._blockchain }
  let!(:award_type) { create :award_type, project: project }
  let!(:award) { create :award, award_type: award_type, issuer: issuer }
  let!(:channel) { create :channel, project: project, team: team, channel_id: 'channel' }

  before do
    team.build_authentication_team authentication
  end

  subject { (create :award, award_type: award_type, issuer: issuer, account: recipient).decorate }
  specify { expect(subject.issuer_display_name).to eq('johnny johnny') }
  specify { expect(subject.issuer_user_name).to eq('johnny johnny') }
  specify { expect(subject.issuer_address).to eq('0xD8655aFe58B540D8372faaFe48441AeEc3bec453') }
  specify { expect(subject.recipient_display_name).to eq('Betty Ross') }
  specify { expect(subject.recipient_user_name).to eq('Betty Ross') }
  specify { expect(subject.recipient_address).to eq('0xD8655aFe58B540D8372faaFe48441AeEc3bec423') }

  it 'returns ethereum_transaction_address_short' do
    award = create :award, ethereum_transaction_address: '0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
    expect(award.decorate.ethereum_transaction_address_short).to eq '0xb808727d...'
  end

  it 'returns ethereum_transaction_explorer_url' do
    award = create :award, ethereum_transaction_address: '0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
    expect(award.decorate.ethereum_transaction_explorer_url.include?('/tx/0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb')).to be_truthy
  end

  it 'returns ethereum_transaction_explorer_url for qtum' do
    award = create :award, ethereum_transaction_address: 'b808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
    award.project.token._blockchain = 'qtum_test'
    expect(award.decorate.ethereum_transaction_explorer_url.include?('/tx/b808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb')).to be_truthy
  end

  it 'returns amount_pretty' do
    award = create :award, amount: 2.34
    expect(award.decorate.amount_pretty).to eq '2.34000000'
  end

  it 'returns total_amount_pretty' do
    award = create :award, quantity: 2.5
    expect(award.decorate.total_amount_pretty).to eq '125.00000000'

    award = create :award, quantity: 25
    expect(award.decorate.total_amount_pretty).to eq '1,250.00000000'

    award.token.update decimal_places: 2
    expect(award.decorate.total_amount_pretty).to eq '1,250.00'
  end

  it 'returns part_of_email' do
    award = create :award, quantity: 2.5, email: 'test@test.st'
    expect(award.decorate.part_of_email).to eq 'test@...'
  end

  it 'returns communication_channel' do
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
    let!(:project) { create(:project, token: create(:token, contract_address: '0x8023214bf21b1467be550d9b889eca672355c005', _token_type: :comakery_security_token, _blockchain: :ethereum_ropsten)) }
    let!(:eth_award) { create(:award, status: :accepted, award_type: create(:award_type, project: project)) }
    let!(:mint_award) { create(:award, status: :accepted, transfer_type: project.transfer_types.find_by(name: 'mint'), award_type: create(:award_type, project: project)) }
    let!(:burn_award) { create(:award, status: :accepted, transfer_type: project.transfer_types.find_by(name: 'burn'), award_type: create(:award_type, project: project)) }

    it 'returns text based on transfer type' do
      expect(eth_award.decorate.transfer_button_text).to eq('Pay')
      expect(mint_award.decorate.transfer_button_text).to eq('Mint')
      expect(burn_award.decorate.transfer_button_text).to eq('Burn')
    end
  end

  describe 'transfer_button_state_class' do
    let!(:award_created_not_expired) { create(:blockchain_transaction, status: :created, created_at: 1.year.from_now).blockchain_transactable }
    let!(:award_pending) { create(:blockchain_transaction, status: :pending, tx_hash: '0').blockchain_transactable }
    let!(:award_created_expired) { create(:blockchain_transaction, status: :created, created_at: 1.year.ago).blockchain_transactable }
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

  describe '#show_prioritize_button?' do
    let(:award) { tx.blockchain_transactable.decorate }
    let(:hot_wallet_mode) { :auto_sending }

    subject { award.show_prioritize_button? }

    before do
      award.project.update!(hot_wallet_mode: hot_wallet_mode)
    end

    context 'for not created tx' do
      let(:tx) { nil }
      let(:award) { create(:award).decorate }

      it { is_expected.to be true }
    end

    context 'for not created tx and disabled hot wallet mode' do
      let(:tx) { nil }
      let(:award) { create(:award).decorate }
      let(:hot_wallet_mode) { :disabled }

      it { is_expected.to be false }
    end

    context 'for tx with created status' do
      let(:tx) { create(:blockchain_transaction, status: :created) }

      it { is_expected.to be true }
    end

    context 'for tx with pending status' do
      let(:tx) { create(:blockchain_transaction, status: :pending, tx_hash: 'tx hash') }

      it { is_expected.to be false }
    end

    context 'for tx with cancelled status' do
      let(:tx) { create(:blockchain_transaction, status: :cancelled, tx_hash: 'tx hash') }

      it { is_expected.to be true }
    end

    context 'for tx with succeed status' do
      let(:tx) { create(:blockchain_transaction, status: :succeed, tx_hash: 'tx hash') }

      it { is_expected.to be false }
    end

    context 'for tx with failed status' do
      let(:tx) { create(:blockchain_transaction, status: :failed, tx_hash: 'tx hash') }

      it { is_expected.to be false }
    end

    context 'for tx with failed status and hot wallet in manual mode' do
      let(:tx) { create(:blockchain_transaction, status: :failed, tx_hash: 'tx hash') }
      let(:hot_wallet_mode) { :manual_sending }

      it { is_expected.to be true }
    end
  end

  describe '#to_csv_header' do
    subject { award.decorate.to_csv_header }

    let(:columns) do
      [
        'Id',
        'Transfer Type',
        'Recipient Id',
        'Recipient First Name',
        'Recipient Last Name',
        'Recipient Blockchain Address',
        'Recipient Verification',
        'Sender Id',
        'Sender First Name',
        'Sender Last Name',
        'Sender Blockchain Address',
        "Total Amount #{award.token&.symbol}",
        'Transaction Hash',
        'Transaction Blockchain',
        'Transferred At',
        'Created At'
      ]
    end

    it { is_expected.to eq(columns) }

    context 'without token' do
      before do
        allow(award).to receive(:token).and_return(nil)
      end

      it { is_expected.to eq(columns) }
    end
  end

  describe '#to_csv' do
    let(:blockchain_transaction) { create(:blockchain_transaction) }
    let(:award) { blockchain_transaction.blockchain_transactable }

    subject { award.decorate.to_csv }

    let(:columns) do
      [
        award.id,
        award.transfer_type&.name,
        award.account&.managed_account_id || award.account&.id,
        award.account&.first_name,
        award.account&.last_name,
        award.recipient_wallet&.address,
        award.account&.decorate&.verification_state,
        award.issuer.managed_account_id || award.issuer.id,
        award.issuer.first_name,
        award.issuer.last_name,
        award.latest_blockchain_transaction&.source,
        award.total_amount,
        award.latest_blockchain_transaction&.tx_hash,
        award.token&.blockchain&.name,
        award.transferred_at,
        award.created_at
      ]
    end

    it { is_expected.to eq(columns) }

    context 'with managed account ids' do
      before do
        allow(award).to receive(:account).and_return(create(:account, managed_account_id: '0'))
        allow(award).to receive(:issuer).and_return(create(:account, managed_account_id: '1'))
      end

      it { is_expected.to eq(columns) }
    end

    context 'without account' do
      before do
        allow(award).to receive(:account).and_return(nil)
      end

      it { is_expected.to eq(columns) }
    end

    context 'without recipient_wallet' do
      before do
        allow(award).to receive(:recipient_wallet).and_return(nil)
      end

      it { is_expected.to eq(columns) }
    end

    context 'without latest_blockchain_transaction' do
      before do
        allow(award).to receive(:latest_blockchain_transaction).and_return(nil)
      end

      it { is_expected.to eq(columns) }
    end

    context 'without token' do
      before do
        allow(award).to receive(:token).and_return(nil)
      end

      it { is_expected.to eq(columns) }
    end
  end
end
