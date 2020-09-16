module TezosAddressable
  extend ActiveSupport::Concern

  class TezosAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      validate_format(record, attribute, value) if value.present?
    end

    def validate_format(record, attribute, value)
      unless /\A(tz1)[a-zA-Z0-9]{33}\z/.match?(value)
        message = options[:message] || "should start with 'tz1', " \
          'followed by 33 characters'
        record.errors.add attribute, message
      end
    end
  end
end
