module EthereumAddressable
  extend ActiveSupport::Concern

  class EthereumAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      validate_format(record, attribute, value) if value.present?
      validate_immutable(record, attribute) if options[:immutable]
    end

    def validate_format(record, attribute, value)
      address = Comakery::Ethereum::ADDRESS[options[:type]]
      unless address
        raise ArgumentError, "type (#{Comakery::Ethereum::ADDRESS.keys.join('|')}) is required, " \
                'for example: ' \
                '`validates :my_field, ethereum_address: {type: :account}`'
      end
      length = address.fetch(:length)
      if value !~ /\A0x[0-9a-fA-F]{#{length}}\z/
        message = options[:message] || "should start with '0x', " \
          "followed by a #{length} character ethereum address"
        record.errors.add attribute, message
      end
    end

    def validate_immutable(record, attribute)
      if record.send("#{attribute}_was").present? && record.send("#{attribute}_changed?")
        record.errors.add attribute, 'cannot be changed after it has been set'
      end
    end
  end
end
