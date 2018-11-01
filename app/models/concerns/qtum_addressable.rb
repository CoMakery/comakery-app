module QtumAddressable
  extend ActiveSupport::Concern

  class QtumAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      validate_format(record, attribute, value) if value.present?
      validate_immutable(record, attribute) if options[:immutable]
    end

    def validate_format(record, attribute, value)
      if value !~ /\A[qQ][a-km-zA-HJ-NP-Z0-9]{33}\z/
        message = options[:message] || "should start with 'Q', " \
          'followed by 33 characters'
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
