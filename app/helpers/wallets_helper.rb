module WalletsHelper
  def wallet_blockchain_collection(wallet)
    wallet.available_blockchains.map { |k| [Wallet.blockchain_for(k).name, k] }
  end
end
