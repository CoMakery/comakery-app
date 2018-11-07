class UtilitiesService
  def self.get_wallet_url(network, wallet)
    case network
    when 'qtum_mainnet'
      "https://explorer.qtum.org/address/#{wallet}"
    when 'qtum_testnet'
      "https://testnet.qtum.org/address/#{wallet}"
    else
      if network == 'main'
        "https://etherscan.io/address/#{wallet}"
      elsif network.present?
        "https://#{network}.etherscan.io/address/#{wallet}"
      else
        'javascript:void(0);'
      end
    end
  end
end
