class BitcoinAddressValidatorSchmoozer < Schmooze::Base
  # rubocop:todo Rails/FilePath
  dependencies bitcoinAddressValidator: "#{Rails.root}/lib/assets/javascripts/bitcoin_address_validator"
  # rubocop:enable Rails/FilePath

  method :is_valid_bitcoin_address, 'bitcoinAddressValidator.checkValidBitcoinAddress'
end
