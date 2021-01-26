module ActiveStorageValidator
  extend ActiveSupport::Concern

  class_methods do
    def validate_image_attached(*fields)
      fields.each do |field|
        validates field, content_type: %w[image/png image/jpg image/jpeg],
                         size: { less_than: 10.megabytes, message: 'is not given between size' },
                         dimension: { min: 1..1 }
      end
    end
  end
end
