module ConstellationAddressable
  extend ActiveSupport::Concern

  class ConstellationAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value.present?
        validate_format(record, attribute, value)
        validate_checksum(record, attribute, value)
      end
    end

    def validate_format(record, attribute, value)
      if value !~ /^DAG\d[1-9A-HJ-NP-Za-km-z]{36}$/
        message = options[:message] || "should start with 'DAG', " \
          'followed by 37 characters'
        record.errors.add attribute, message
      end
    end

    def validate_checksum(record, attribute, value)
      included_checksum = value[3]&.to_i
      computed_checksum = value[4..-1]&.scan(/\d/)&.map(&:to_i)&.reduce(&:+)&.modulo(9)

      if included_checksum != computed_checksum
        message = options[:message] || 'should include valid checksum'
        record.errors.add attribute, message
      end
    end
  end
end
