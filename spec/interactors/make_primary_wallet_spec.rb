require 'rails_helper'

describe MakePrimaryWallet do
  let(:account) { create(:account) }
  let!(:wallet_1) { create(:wallet, account: account, primary_wallet: true) }
  let(:wallet_2) do
    create(:wallet, account: account, _blockchain: wallet_1._blockchain, address: wallet_1.address, primary_wallet: false)
  end

  it 'make given wallet primary' do
    MakePrimaryWallet.call(account: account, wallet: wallet_2)
    wallet_1.reload
    wallet_2.reload

    expect(wallet_2.primary_wallet).to eq(true)
    expect(wallet_1.primary_wallet).to eq(false)
  end
end
