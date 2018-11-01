class UtilitiesService
  def self.get_wallet_url(network, wallet)
    if network.blank? || network == 'main'
      "https://etherscan.io/address/#{wallet}"
    else
      "https://#{network}.etherscan.io/address/#{wallet}"
    end
  end
end
