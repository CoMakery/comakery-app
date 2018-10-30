class UtilitiesService
  def self.get_wallet_url(network, wallet)
    "https://#{network}.etherscan.io/address/#{wallet}"
  end
end
