class CardanoAddressValidatorSchmoozer < Schmooze::Base
  # rubocop:todo Rails/FilePath
  dependencies cardanoAddressValidator: "#{Rails.root}/lib/assets/javascripts/cardano_address_validator"
  # rubocop:enable Rails/FilePath

  method :is_valid_address, 'cardanoAddressValidator.checkValidAddress'
end
