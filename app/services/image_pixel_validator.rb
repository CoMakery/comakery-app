class ImagePixelValidator
  def initialize(record, params)
    @record = record
    @params = params
  end

  def valid?
    attachments.all? { |attr, attachment| valid_pixel_dimensions? attr, image_size(attachment) }
  end

  private

    attr_accessor :record
    attr_reader   :params

    def valid_pixel_dimensions?(attr, image_size)
      return true if image_size && image_size[0] <= max_pixel_dimensions[0] && image_size[1] <= max_pixel_dimensions[1]

      record.errors.add(attr.to_sym, 'exceeds maximum pixel dimensions')

      false
    end

    def image_size(attachment)
      FastImage.size(attachment.tempfile)
    end

    def attachments
      params.to_h.slice(*attachment_keys)
    end

    def attachment_keys
      record.attachment_reflections.keys
    end

    def max_pixel_dimensions
      [4096, 4096]
    end
end
