module ConstellationAddressable
  extend ActiveSupport::Concern

  class ConstellationAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      validate_format(record, attribute, value) if value.present?
    end

    def validate_format(record, attribute, value)
      if value !~ /\ADAG[a-zA-Z0-9]{37}\z/
        message = options[:message] || "should start with 'DAG', " \
          'followed by 37 characters'
        record.errors.add attribute, message
      end
    end
  end
end
