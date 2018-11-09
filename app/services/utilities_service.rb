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

  def self.get_transaction_url(network, tx)
    case network
    when 'qtum_mainnet'
      "https://explorer.qtum.org/tx/#{tx}"
    when 'qtum_testnet'
      "https://testnet.qtum.org/tx/#{tx}"
    end
  end

  def self.get_contract_url(network, contract_address)
    url = case network
          when 'qtum_mainnet'
            "https://explorer.qtum.org/token/#{contract_address}"
          when 'qtum_testnet'
            "https://testnet.qtum.org/token/#{contract_address}"
    end
    url = nil if contract_address.blank?
    url
  end
end
