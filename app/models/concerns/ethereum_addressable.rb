module EthereumAddressable
  extend ActiveSupport::Concern

  class EthereumAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return if value.blank?
      length = options[:length] || raise(ArgumentError.new("length is required, for example: `validates :my_field, ethereum_address: {length: 40}`"))
      if value !~ /\A0x[0-9a-fA-F]{#{length}}\z/
        message = options[:message] || "should start with '0x', followed by a #{length} character ethereum address"
        record.errors.add attribute, message
      end
    end
  end
end
