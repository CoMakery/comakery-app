require 'rails_helper'

describe MakePrimaryWallet do
  let(:account) { create(:account) }
  let(:address_1) { '3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt' }
  let(:address_2) { '3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc5' }
  let!(:wallet_1) do
    create(:wallet, account: account, primary_wallet: true, _blockchain: 'bitcoin', address: address_1)
  end
  let(:wallet_2) do
    create(:wallet, account: account, _blockchain: 'bitcoin', address: address_2, primary_wallet: false)
  end

  it 'make given wallet primary' do
    MakePrimaryWallet.call(account: account, wallet: wallet_2)
    wallet_1.reload
    wallet_2.reload

    expect(wallet_2.primary_wallet).to eq(true)
    expect(wallet_1.primary_wallet).to eq(false)
  end
end
