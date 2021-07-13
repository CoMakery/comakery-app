require 'rails_helper'

describe AwardDecorator do
  let(:issuer) { FactoryBot.create :account, first_name: 'johnny', last_name: 'johnny' }
  let(:recipient) { FactoryBot.create :account, first_name: 'Betty', last_name: 'Ross' }
  let(:token) { FactoryBot.create(:token, _token_type: 'eth', _blockchain: :ethereum_ropsten) }
  let(:project) { FactoryBot.create :project, account: issuer, token: token }
  let(:award_type) { FactoryBot.create :award_type, project: project }
  let(:award) do
    FactoryBot.create :award, award_type: award_type, issuer: issuer, transfer_type: transfer_type
  end
  let(:account) { FactoryBot.create(:account) }
  let(:project) { FactoryBot.create :project, token: token, account: account }
  let(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
  let(:ethereum_transaction_address) do
    '0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
  end

  shared_context 'with award blockchain transactions' do
    let(:transaction_batch) { FactoryBot.create :transaction_batch }
    let(:transaction1) do
      FactoryBot.create :blockchain_transaction,
                        status: :created, token: token, transaction_batch: transaction_batch,
                        source: 'src1', destination: 'dest1'
    end
    let(:transaction2) do
      FactoryBot.create :blockchain_transaction,
                        status: :succeed, token: token, transaction_batch: transaction_batch,
                        source: 'src2', destination: 'dest2'
    end
    let(:transaction3) do
      FactoryBot.create :blockchain_transaction,
                        status: :cancelled, token: token, transaction_batch: transaction_batch,
                        source: 'src3', destination: 'dest3'
    end
    let(:transaction4) do
      FactoryBot.create :blockchain_transaction,
                        status: :succeed, token: token, transaction_batch: transaction_batch,
                        source: 'src4', destination: 'dest4'
    end
    let(:transaction5) do
      FactoryBot.create :blockchain_transaction,
                        status: :failed, token: token, transaction_batch: transaction_batch,
                        source: 'src5', destination: 'dest5'
    end
    let(:transaction6) do
      FactoryBot.create :blockchain_transaction,
                        status: :created, token: token, transaction_batch: transaction_batch,
                        source: 'src6', destination: 'dest6'
    end
    let(:blockchain_transactions) do
      transactions =
        [transaction1, transaction2, transaction3, transaction4, transaction5, transaction6]
      BlockchainTransaction.where(id: transactions).all
    end

    before do
      allow_any_instance_of(Token).to receive(:_token_type_on_ethereum?).and_return(true)
      allow(award).to receive(:blockchain_transactions).and_return(blockchain_transactions)
    end
  end

  subject { (create :award, award_type: award_type, issuer: issuer, account: recipient).decorate }
  specify { expect(subject.issuer_display_name).to eq('johnny johnny') }
  specify { expect(subject.issuer_user_name).to eq('johnny johnny') }
  specify { expect(subject.recipient_display_name).to eq('Betty Ross') }
  specify { expect(subject.recipient_user_name).to eq('Betty Ross') }

  describe '#issuer_address' do
    subject(:issuer_address) { award.decorate.issuer_address }

    let(:award) do
      FactoryBot.create :award, award_type: award_type, issuer: issuer, account: recipient,
                                project: project, transfer_type: transfer_type
    end
    let!(:wallet_issuer) do
      FactoryBot.create :wallet, account: issuer, _blockchain: token._blockchain,
                                 address: '0xD8655aFe58B540D8372faaFe48441AeEc3bec453'
    end

    it 'should return issuer wallet address' do
      expect(issuer_address).to eq '0xD8655aFe58B540D8372faaFe48441AeEc3bec453'
    end
  end

  describe '#sender_wallet_url' do
    subject(:sender_wallet_url) { award.decorate.sender_wallet_url }

    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create(:token) }
    let(:project) { FactoryBot.create :project, account: account, token: token }
    let!(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:award_type) { FactoryBot.create(:award_type, project: project) }
    let!(:award) do
      FactoryBot.create :award, account: account, status: :paid, award_type: award_type,
                                transfer_type: transfer_type, issuer: account
    end

    context 'when sender wallet address is present' do
      let(:transaction_batch) { FactoryBot.create :transaction_batch }
      let(:transaction) do
        FactoryBot.create :blockchain_transaction,
                          status: :succeed, token: token, transaction_batch: transaction_batch,
                          source: 'src2', destination: 'dest2'
      end
      let(:blockchain_transactions) { BlockchainTransaction.where(id: transaction.id).all }

      before do
        allow_any_instance_of(Token).to receive(:_token_type_on_ethereum?).and_return(true)
        allow(award).to receive(:blockchain_transactions).and_return(blockchain_transactions)
      end

      it 'should return correct sender wallet url' do
        expect(sender_wallet_url).to eq 'https://live.blockcypher.com/btc/address/src2'
      end
    end

    context 'when sender wallet address is not present' do
      it 'should return nil' do
        expect(sender_wallet_url).to eq nil
      end
    end
  end

  describe '#recipient_address' do
    subject(:recipient_address) { award.decorate.recipient_address }

    let(:award) do
      FactoryBot.create :award, award_type: award_type, issuer: issuer, account: recipient,
                                project: project, transfer_type: transfer_type
    end
    let!(:wallet_recipient) do
      FactoryBot.create :wallet, account: recipient, _blockchain: token._blockchain,
                                 address: '0xD8655aFe58B540D8372faaFe48441AeEc3bec423'
    end

    it 'should return recipient wallet address' do
      expect(recipient_address).to eq '0xD8655aFe58B540D8372faaFe48441AeEc3bec423'
    end
  end

  describe '#recipient_wallet_url' do
    subject(:recipient_wallet_url) { award.decorate.recipient_wallet_url }

    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create(:token) }
    let(:project) { FactoryBot.create :project, account: account, token: token }
    let!(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:award_type) { FactoryBot.create(:award_type, project: project) }
    let!(:award) do
      FactoryBot.create :award, account: account, status: :paid, award_type: award_type,
                                transfer_type: transfer_type, issuer: account,
                                recipient_wallet: wallet
    end

    context 'when recipient wallet is present' do
      let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }

      it 'should return correct recipient wallet url' do
        expect(recipient_wallet_url)
          .to eq "https://live.blockcypher.com/btc/address/#{wallet.address}"
      end
    end

    context 'when recipient wallet is not present' do
      let(:wallet) { nil }

      it 'should return nil' do
        expect(recipient_wallet_url).to eq nil
      end
    end
  end

  describe '#ethereum_transaction_address_short' do
    subject(:ethereum_transaction_address_short) do
      award.decorate.ethereum_transaction_address_short
    end

    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create :token }
    let(:project) { FactoryBot.create :project, token: token, account: account }
    let(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:award) do
      FactoryBot.create :award, project: project, transfer_type: transfer_type, issuer: account,
                                ethereum_transaction_address: ethereum_transaction_address
    end

    it 'should return shortened ethereum transaction address' do
      expect(award.decorate.ethereum_transaction_address_short).to eq '0xb808727d...'
    end
  end

  describe '#ethereum_transaction_explorer_url' do
    subject(:ethereum_transaction_explorer_url) do
      award.decorate.ethereum_transaction_explorer_url
    end

    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create :token }
    let(:project) { FactoryBot.create :project, token: token, account: account }
    let(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:award) do
      FactoryBot.create :award, project: project, transfer_type: transfer_type, issuer: account,
                                ethereum_transaction_address: ethereum_transaction_address
    end

    it 'should return ethereum transaction explorer url' do
      expect(ethereum_transaction_explorer_url)
        .to match '/tx/0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
    end

    context 'with qtum' do
      let(:token) { FactoryBot.create :token, _blockchain: 'qtum_test' }

      it 'should return ethereum transaction explorer url' do
        expect(ethereum_transaction_explorer_url)
          .to match '/tx/0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
      end
    end
  end

  describe '#amount_pretty' do
    subject(:amount_pretty) { award.decorate.amount_pretty }

    context 'with token with decimal places' do
      let(:account) { FactoryBot.create(:account) }
      let(:token) { FactoryBot.create :token, decimal_places: 8 }
      let(:project) { FactoryBot.create :project, token: token, account: account }
      let(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
      let(:award) do
        FactoryBot.create :award, project: project, transfer_type: transfer_type, issuer: account,
                                  amount: 2.34
      end

      it 'should return amount in pretty format' do
        expect(amount_pretty).to eq '2.34000000'
      end
    end

    context 'without token' do
      let(:award) { FactoryBot.build_stubbed :award, amount: 2.34 }

      it 'should return amount in pretty format' do
        expect(amount_pretty).to eq '2'
      end
    end
  end

  describe '#total_amount_pretty' do
    subject(:total_amount_pretty) { award.decorate.total_amount_pretty }

    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create :token, decimal_places: 8 }
    let(:project) { FactoryBot.create :project, token: token, account: account }
    let(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }

    context 'with amount 50 and quantity 2.5' do
      let(:award) do
        FactoryBot.create :award, project: project, transfer_type: transfer_type, issuer: account,
                                  amount: 50, quantity: 2.5
      end

      it 'should return formatted total amount' do
        expect(total_amount_pretty).to eq '125.00000000'
      end
    end

    context 'with amount 50 and quantity 25' do
      let(:award) do
        FactoryBot.create :award, project: project, transfer_type: transfer_type, issuer: account,
                                  amount: 50, quantity: 25
      end

      it 'should return formatted total amount' do
        expect(total_amount_pretty).to eq '1,250.00000000'
      end
    end

    context 'with amount 50 and quantity 25 and decimal places 2' do
      let(:token) { FactoryBot.create :token, decimal_places: 2 }
      let(:award) do
        FactoryBot.create :award, project: project, transfer_type: transfer_type, issuer: account,
                                  amount: 50, quantity: 25
      end

      it 'should return formatted total amount' do
        expect(total_amount_pretty).to eq '1,250.00'
      end
    end
  end

  it 'returns part_of_email' do
    award = create :award, quantity: 2.5, email: 'test@test.st'
    expect(award.decorate.part_of_email).to eq 'test@...'
  end

  it 'returns communication_channel' do
    authentication = FactoryBot.create :authentication, account: issuer
    team = FactoryBot.create :team
    channel = create :channel, project: project, team: team, channel_id: 'channel'
    team.build_authentication_team authentication

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
      expect(award_18_decimals.decorate.total_amount_wei).to eq(2_000_000_000_000_000_000)
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

  describe '#sender_wallet_address' do
    subject(:sender_wallet_address) { award.decorate.sender_wallet_address }

    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create(:token) }
    let(:project) { FactoryBot.create :project, account: account, token: token }
    let!(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:award_type) { FactoryBot.create(:award_type, project: project) }
    let!(:award) do
      FactoryBot.create :award, account: account, status: status, award_type: award_type,
                                transfer_type: transfer_type, issuer: account
    end

    include_context 'with award blockchain transactions'

    context 'when award is paid' do
      let(:status) { :paid }

      context 'when there are succeed transactions' do
        it 'should return source of last succeeded blockchain transaction' do
          expect(sender_wallet_address).to eq 'src4'
        end
      end

      context 'when there are no succeed transactions' do
        let(:transaction2) { nil }
        let(:transaction4) { nil }

        it 'should return nil' do
          expect(sender_wallet_address).to eq nil
        end
      end
    end

    %i[ready started submitted accepted rejected cancelled invite_ready].each do |status_value|
      let(:status) { status_value }

      context "when award is #{status_value}" do
        it 'should return nil' do
          expect(sender_wallet_address).to eq nil
        end
      end
    end
  end

  describe '#recipient_wallet_address' do
    subject(:recipient_wallet_address) { award.decorate.recipient_wallet_address }

    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create(:token) }
    let(:project) { FactoryBot.create :project, account: account, token: token }
    let!(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:award_type) { FactoryBot.create(:award_type, project: project) }
    let!(:award) do
      FactoryBot.create :award, account: account, award_type: award_type,
                                transfer_type: transfer_type, issuer: account,
                                recipient_wallet: wallet
    end

    context 'when recipient wallet is present' do
      let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }

      it 'should return correct recipient wallet address' do
        expect(recipient_wallet_address).to eq wallet.address
      end
    end

    context 'when recipient wallet is not present' do
      let(:wallet) { nil }

      it 'should return nil' do
        expect(recipient_wallet_address).to eq nil
      end
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
        'Recipient Email',
        'Recipient Blockchain Address',
        'Recipient Verification',
        'Sender Id',
        'Sender First Name',
        'Sender Last Name',
        'Sender Blockchain Address',
        "Total Amount #{award.token&.symbol}",
        'Transaction Hash',
        'Transaction Blockchain',
        'Transfer Status',
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
        award.account&.email,
        award.recipient_wallet&.address,
        award.account&.decorate&.verification_state,
        award.issuer.managed_account_id || award.issuer.id,
        award.issuer.first_name,
        award.issuer.last_name,
        award.latest_blockchain_transaction&.source,
        award.total_amount,
        award.latest_blockchain_transaction&.tx_hash,
        award.token&.blockchain&.name,
        award.status,
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
