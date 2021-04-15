module WalletsHelper
  def wallet_blockchain_collection(wallet)
    wallet.available_blockchains.map { |k| [Wallet.blockchain_for(k).name, k] }
  end

  def ore_id_configured
    ENV['ORE_ID_API_KEY'] && ENV['ORE_ID_SERVICE_KEY']
  end
end
