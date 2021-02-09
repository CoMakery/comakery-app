require 'rails_helper'

describe AccountTokenRecord do
  describe 'associations' do
    let(:token) { create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten) }
    let(:reg_group) { create(:reg_group, token: token) }
    let(:account) { create(:account) }
    let(:wallet) { create(:wallet, address: build(:ethereum_contract_address), account: account, _blockchain: token._blockchain) }
    let!(:account_token_record) { create(:account_token_record, token: token, reg_group: reg_group, account: account, wallet: wallet) }

    it 'belongs to token' do
      expect(account_token_record.token).to eq(token)
    end

    it 'belongs to account' do
      expect(account_token_record.account).to eq(account)
    end

    it 'belongs to reg_group' do
      expect(account_token_record.reg_group).to eq(reg_group)
    end
  end

  describe 'callbacks' do
    it 'sets default values' do
      account_token_record = described_class.new(token: create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten))

      expect(account_token_record.lockup_until).not_to be_nil
      expect(account_token_record.reg_group).not_to be_nil
    end

    it 'sets a wallet on before_validation' do
      account_token_record = build(:account_token_record)
      account_token_record.wallet = nil
      account_token_record.valid?

      expect(account_token_record.wallet).to eq account_token_record.account.wallets.first
    end
  end

  describe 'validations' do
    it 'requires comakery token' do
      account_token_record = create(:account_token_record)
      account_token_record.token = create(:token)
      expect(account_token_record).not_to be_valid
    end

    it 'requires lockup_until to be not less than min value' do
      account_token_record = build(:account_token_record, lockup_until: described_class::LOCKUP_UNTIL_MIN - 1)
      expect(account_token_record).not_to be_valid
    end

    it 'requires lockup_until to be not greater than max value' do
      account_token_record = build(:account_token_record, lockup_until: described_class::LOCKUP_UNTIL_MAX + 1)
      expect(account_token_record).not_to be_valid
    end

    it 'requires balance to be not less than min value' do
      account_token_record = build(:account_token_record, balance: described_class::BALANCE_MIN - 1)
      expect(account_token_record).not_to be_valid
    end

    it 'requires balance to be not greater than max value' do
      account_token_record = build(:account_token_record, balance: described_class::BALANCE_MAX + 1)
      expect(account_token_record).not_to be_valid
    end

    it 'requires max_balance to be not less than min value' do
      account_token_record = build(:account_token_record, max_balance: described_class::BALANCE_MIN - 1)
      expect(account_token_record).not_to be_valid
    end

    it 'requires max_balance to be not greater than max value' do
      account_token_record = build(:account_token_record, max_balance: described_class::BALANCE_MAX + 1)
      expect(account_token_record).not_to be_valid
    end
  end

  describe 'lockup_until' do
    let!(:max_uint256) { 115792089237316195423570985008687907853269984665640564039458 }
    let!(:account_token_record) { create(:account_token_record, lockup_until: Time.zone.at(max_uint256)) }

    it 'stores Time as a high precision decimal (which able to fit uint256) and returns Time object initialized from decimal' do
      expect(account_token_record.reload.lockup_until).to eq(Time.zone.at(max_uint256))
    end
  end

  describe 'ready_for_blockchain_transaction scope' do
    let!(:account_token_record) { create(:account_token_record) }
    let!(:blockchain_transaction) { create(:blockchain_transaction_account_token_record) }

    it 'returns account_token_records without blockchain_transaction' do
      expect(described_class.ready_for_blockchain_transaction).to include(account_token_record)
    end

    it 'returns account_token_records with latest blockchain_transaction Cancelled' do
      create(:blockchain_transaction_account_token_record, status: :cancelled, blockchain_transactable: blockchain_transaction.blockchain_transactable)

      expect(described_class.ready_for_blockchain_transaction).to include(blockchain_transaction.blockchain_transactable)
    end

    it 'returns account_token_records with latest blockchain_transaction Created more than 10 minutes ago' do
      create(:blockchain_transaction_account_token_record, blockchain_transactable: blockchain_transaction.blockchain_transactable, created_at: 20.minutes.ago)

      expect(described_class.ready_for_blockchain_transaction).to include(blockchain_transaction.blockchain_transactable)
    end

    it 'doesnt return account_token_records with lates blockchain_transaction Created less than 10 minutes ago' do
      create(:blockchain_transaction_account_token_record, blockchain_transactable: blockchain_transaction.blockchain_transactable, created_at: 1.second.ago)

      expect(described_class.ready_for_blockchain_transaction).not_to include(blockchain_transaction.blockchain_transactable)
    end

    it 'doesnt return account_token_records with latest blockchain_transaction Pending' do
      create(:blockchain_transaction_account_token_record, status: :pending, blockchain_transactable: blockchain_transaction.blockchain_transactable)

      expect(described_class.ready_for_blockchain_transaction).not_to include(blockchain_transaction.blockchain_transactable)
    end

    it 'doesnt return account_token_records with latest blockchain_transaction Succeed' do
      create(:blockchain_transaction_account_token_record, status: :succeed, blockchain_transactable: blockchain_transaction.blockchain_transactable)

      expect(described_class.ready_for_blockchain_transaction).not_to include(blockchain_transaction.blockchain_transactable)
    end

    it 'doesnt return account_token_records with latest blockchain_transaction Failed' do
      create(:blockchain_transaction_account_token_record, status: :failed, blockchain_transactable: blockchain_transaction.blockchain_transactable)

      expect(described_class.ready_for_blockchain_transaction).not_to include(blockchain_transaction.blockchain_transactable)
    end
  end

  describe 'ready_for_manual_blockchain_transaction scope' do
    let!(:blockchain_transaction) { create(:blockchain_transaction_account_token_record) }

    it 'returns account_token_records with latest blockchain_transaction Failed' do
      create(:blockchain_transaction_account_token_record, status: :failed, blockchain_transactable: blockchain_transaction.blockchain_transactable)

      expect(described_class.ready_for_manual_blockchain_transaction).to include(blockchain_transaction.blockchain_transactable)
    end
  end

  describe 'replace_existing_record' do
    let!(:account_token_record) { create(:account_token_record) }
    let!(:account_token_record_dup) { create(:account_token_record, token: account_token_record.token, account: account_token_record.account, status: :synced) }
    let!(:account_token_record_dup_account) { create(:account_token_record, account: account_token_record.account, status: :synced) }

    context 'when status synced' do
      before do
        account_token_record.synced!
      end

      it 'deletes all synced records with the same combination of token and account' do
        expect { account_token_record_dup.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'doesnt delete records with same account but different token' do
        expect { account_token_record_dup_account.reload }.not_to raise_error
      end
    end

    context 'when status not synced' do
      it 'does nothing' do
        expect { account_token_record.reload }.not_to raise_error
        expect { account_token_record_dup.reload }.not_to raise_error
        expect { account_token_record_dup_account.reload }.not_to raise_error
      end
    end
  end
end
