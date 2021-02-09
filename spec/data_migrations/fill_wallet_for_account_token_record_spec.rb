require 'rails_helper'
require Rails.root.join('db/data_migrations/20210111085831_fill_wallet_for_account_token_record')

describe FillWalletForAccountTokenRecord do
  subject { described_class.new.up }

  it 'update all empty wallets' do
    record_with_filled_wallet = create(:account_token_record)
    record_without_wallet = create(:account_token_record, wallet: nil)
    account_with_wallet = create(:account)
    account_with_wallet.wallets << create(:wallet, _blockchain: :ethereum_ropsten, address: build(:ethereum_address_1))
    record_with_account_wallet = create(:account_token_record, wallet: nil, account: account_with_wallet)

    expect(record_with_filled_wallet.wallet).to eq record_with_filled_wallet.account.wallets.first
    expect(record_without_wallet.wallet).to be nil
    expect(record_without_wallet.account.wallets.count).to be_zero
    expect(record_with_account_wallet.account.wallets.count).to eq 1

    subject
    record_with_filled_wallet.reload
    record_without_wallet.reload
    record_with_account_wallet.reload

    # didn't change
    expect(record_with_filled_wallet.wallet).to eq record_with_filled_wallet.account.wallets.first
    expect(record_without_wallet.wallet).to be nil
    expect(record_without_wallet.account.wallets.count).to be_zero
    expect(record_without_wallet.account.wallets.count).to be_zero

    # filled
    expect(record_with_account_wallet.account.wallets.count).to eq 1
    expect(record_with_account_wallet.wallet).to eq account_with_wallet.wallets.first
  end
end
