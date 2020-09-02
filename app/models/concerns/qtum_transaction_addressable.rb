module QtumTransactionAddressable
  extend ActiveSupport::Concern

  class QtumTransactionAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      validate_format(record, attribute, value) if value.present?
      validate_immutable(record, attribute) if options[:immutable]
    end

    def validate_format(record, attribute, value)
      unless /\A[0-9a-fA-F]{64}\z/.match?(value)
        message = options[:message] || 'should have 64 characters, ' \
          "should not start with '0x'"
        record.errors.add attribute, message
      end
    end

    def validate_immutable(record, attribute)
      record.errors.add attribute, 'cannot be changed after it has been set' if record.send("#{attribute}_was").present? && record.send("#{attribute}_changed?")
    end
  end
end
