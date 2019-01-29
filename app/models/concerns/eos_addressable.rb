module EosAddressable
  extend ActiveSupport::Concern

  class EosAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      validate_format(record, attribute, value) if value.present?
    end

    def validate_format(record, attribute, value)
      if value !~ /\A[a-z1-5]{12}\z/
        message = options[:message] || 'a-z,1-5 are allowed only, the length is 12 characters'
        record.errors.add attribute, message
      end
    end
  end
end
