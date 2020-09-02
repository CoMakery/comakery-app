module QtumContractAddressable
  extend ActiveSupport::Concern

  class QtumContractAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      validate_format(record, attribute, value) if value.present?
    end

    def validate_format(record, attribute, value)
      unless /\A[0-9a-fA-F]{40}\z/.match?(value)
        message = options[:message] || 'should have 40 characters, ' \
          "should not start with '0x'"
        record.errors.add attribute, message
      end
    end
  end
end
