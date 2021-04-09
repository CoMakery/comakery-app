class ImagePixelDimensionValidator
  def initialize(attachments = [])
    @attachments = attachments
  end

  def valid?
    attachments.all? do |attachment|
      image_size = image_size(attachment)

      image_size && image_size[0] <= max_pixel_dimensions[0] && image_size[1] <= max_pixel_dimensions[1]
    end
  end

  def image_size(attachment)
    FastImage.size(attachment.tempfile)
  end

  def max_pixel_dimensions
    [4096, 4096]
  end

  private

    attr_reader :attachments
end
