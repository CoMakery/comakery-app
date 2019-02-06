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
    when 'bitcoin_mainnet', 'bitcoin_testnet', 'cardano_mainnet', 'cardano_testnet', 'qtum_mainnet', 'qtum_testnet', 'eos_mainnet', 'eos_testnet'
      UtilitiesService.send("get_wallet_url_on_#{network}", wallet)
    else
      get_ethereum_wallet_url(network, wallet)
    end
  end

  def self.get_wallet_url_on_bitcoin_mainnet(wallet)
    "https://live.blockcypher.com/btc/address/#{wallet}"
  end

  def self.get_wallet_url_on_bitcoin_testnet(wallet)
    "https://live.blockcypher.com/btc-testnet/address/#{wallet}"
  end

  def self.get_wallet_url_on_cardano_mainnet(wallet)
    "https://cardanoexplorer.com/address/#{wallet}"
  end

  def self.get_wallet_url_on_cardano_testnet(wallet)
    "https://cardano-explorer.cardano-testnet.iohkdev.io/address/#{wallet}"
  end

  def self.get_wallet_url_on_eos_mainnet(wallet)
    "https://explorer.eosvibes.io/account/#{wallet}"
  end

  def self.get_wallet_url_on_eos_testnet(wallet)
    "https://jungle.bloks.io/account/#{wallet}"
  end

  def self.get_wallet_url_on_qtum_mainnet(wallet)
    "https://explorer.qtum.org/address/#{wallet}"
  end

  def self.get_wallet_url_on_qtum_testnet(wallet)
    "https://testnet.qtum.org/address/#{wallet}"
  end

  def self.get_transaction_url(network, tx)
    case network
    when 'bitcoin_mainnet', 'bitcoin_testnet', 'cardano_mainnet', 'cardano_testnet', 'qtum_mainnet', 'qtum_testnet', 'eos_mainnet', 'eos_testnet'
      UtilitiesService.send("get_transaction_url_on_#{network}", tx)
    end
  end

  def self.get_transaction_url_on_bitcoin_mainnet(tx)
    "https://live.blockcypher.com/btc/tx/#{tx}"
  end

  def self.get_transaction_url_on_bitcoin_testnet(tx)
    "https://live.blockcypher.com/btc-testnet/tx/#{tx}"
  end

  def self.get_transaction_url_on_cardano_mainnet(tx)
    "https://cardanoexplorer.com/tx/#{tx}"
  end

  def self.get_transaction_url_on_cardano_testnet(tx)
    "https://cardano-explorer.cardano-testnet.iohkdev.io/tx/#{tx}"
  end

  def self.get_transaction_url_on_qtum_mainnet(tx)
    "https://explorer.qtum.org/tx/#{tx}"
  end

  def self.get_transaction_url_on_qtum_testnet(tx)
    "https://testnet.qtum.org/tx/#{tx}"
  end

  def self.get_transaction_url_on_eos_mainnet(tx)
    "https://explorer.eosvibes.io/transaction/#{tx}"
  end

  def self.get_transaction_url_on_eos_testnet(tx)
    "https://jungle.bloks.io/transaction/#{tx}"
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
