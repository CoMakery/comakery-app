module EthereumAddressable
  extend ActiveSupport::Concern

  class EthereumAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return if value.blank?
      address = Comakery::Ethereum::ADDRESS[options[:type]]
      unless address
        raise(ArgumentError.new(
          "type (#{Comakery::Ethereum::ADDRESS.keys.join('|')}) is required, " \
          "for example: " \
          "`validates :my_field, ethereum_address: {type: :account}`"))
      end
      length = address.fetch(:length)
      if value !~ /\A0x[0-9a-fA-F]{#{length}}\z/
        message = options[:message] || "should start with '0x', " \
          "followed by a #{length} character ethereum address"
        record.errors.add attribute, message
      end
    end
  end
end
