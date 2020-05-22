shared_examples 'blockchain_transactable' do
  it { is_expected.to have_many(:blockchain_transactions) }
  it { is_expected.to have_one(:latest_blockchain_transaction) }
end
