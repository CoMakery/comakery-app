class UtilitiesService
  def self.get_ethereum_wallet_url(network, wallet)
    if network == 'main'
      "https://etherscan.io/address/#{wallet}"
    elsif %w[ropsten kovan rinkeby].include?(network)
      "https://#{network}.etherscan.io/address/#{wallet}"
    else
      'javascript:void(0);'
    end
  end

  def self.get_wallet_url(network, wallet)
    case network
    when 'bitcoin_mainnet'
      "https://insight.bitpay.com/address/#{wallet}"
    when 'bitcoin_testnet'
      "https://test-insight.bitpay.com/address/#{wallet}"
    when 'cardano_mainnet'
      "https://cardanoexplorer.com/address/#{wallet}"
    when 'qtum_mainnet'
      "https://explorer.qtum.org/address/#{wallet}"
    when 'qtum_testnet'
      "https://testnet.qtum.org/address/#{wallet}"
    else
      get_ethereum_wallet_url(network, wallet)
    end
  end

  def self.get_transaction_url(network, tx)
    case network
    when 'cardano_mainnet'
      "https://cardanoexplorer.com/tx/#{tx}"
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
