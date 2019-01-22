class BitcoinAddressValidatorSchmoozer < Schmooze::Base
  dependencies bitcoinAddressValidator: "#{Rails.root}/lib/assets/javascripts/bitcoin_address_validator"

  method :is_valid_bitcoin_address, 'bitcoinAddressValidator.checkValidBitcoinAddress'
end
