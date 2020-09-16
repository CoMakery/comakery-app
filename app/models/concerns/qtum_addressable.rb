module QtumAddressable
  extend ActiveSupport::Concern

  class QtumAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      validate_format(record, attribute, value) if value.present?
    end

    def validate_format(record, attribute, value)
      unless /\A[qQ][a-km-zA-HJ-NP-Z0-9]{33}\z/.match?(value)
        message = options[:message] || "should start with 'Q', " \
          'followed by 33 characters'
        record.errors.add attribute, message
      end
    end
  end
end
