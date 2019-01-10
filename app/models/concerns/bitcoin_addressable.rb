module BitcoinAddressable
  extend ActiveSupport::Concern

  class BitcoinAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      validate_format(record, attribute, value) if value.present?
    end

    def validate_format(record, attribute, value)
      load 'app/schmoozers/bitcoin_address_validator_schmoozer.rb'
      validator = BitcoinAddressValidatorSchmoozer.new(__dir__)

      unless validator.is_valid_bitcoin_address(value)
        message = options[:message] || 'should start with either 1 or 3, ' \
          'make sure the length is between 26 and 35 characters'
        record.errors.add attribute, message
      end
    end
  end
end
