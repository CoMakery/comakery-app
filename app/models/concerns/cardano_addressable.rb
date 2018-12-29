module CardanoAddressable
  extend ActiveSupport::Concern

  class CardanoAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      validate_format(record, attribute, value) if value.present?
    end

    def validate_format(record, attribute, value)
      validator = CardanoAddressValidatorSchmoozer.new(__dir__)

      unless validator.is_valid_address(value)
        message = options[:message] || "should start with 'A', " \
          'followed by 58 characters;' \
          " or should start with 'D', followed by 103 characters"
        record.errors.add attribute, message
      end
    end
  end
end
