module EthereumAddressable
  extend ActiveSupport::Concern

  class EthereumAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return if value.blank?
      if value !~ Rails.configuration.ethereum_address_pattern
        record.errors.add attribute, (options[:message] || "should start with '0x', followed by a 40 character ethereum address")
      end
    end
  end
end
