module EthereumAddressable
  extend ActiveSupport::Concern

  class EthereumAddressValidator < ActiveModel::EachValidator
    ADDRESS = {
      account: {
        length: 40
      },
      transaction: {
        length: 64
      }
    }.freeze

    def validate_each(record, attribute, value)
      validate_format(record, attribute, value) if value.present?
    end

    def validate_format(record, attribute, value)
      address = ADDRESS[options[:type]]

      unless address
        raise ArgumentError, "type (#{ADDRESS.keys.join('|')}) is required, " \
                'for example: ' \
                '`validates :my_field, ethereum_address: {type: :account}`'
      end
      length = address.fetch(:length)
      unless /\A0x[0-9a-fA-F]{#{length}}\z/.match?(value)
        message = options[:message] || "should start with '0x', " \
          "followed by a #{length} character ethereum address"
        record.errors.add attribute, message
      end
    end
  end
end
