class CardanoAddressValidatorSchmoozer < Schmooze::Base
  dependencies cardanoAddressValidator: "#{Rails.root}/lib/assets/javascripts/cardano_address_validator"

  method :is_valid_address, 'cardanoAddressValidator.checkValidAddress'
end
