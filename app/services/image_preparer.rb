# Resize options: https://legacy.imagemagick.org/Usage/resize/#noaspect
class ImagePreparer
  MAX_WIDHT = 4096
  MAX_HEIGHT = 4096
  MAX_SIZE = 2.megabytes

  attr_reader :field_name, :attachment, :options, :error

  def initialize(field_name, attachment, options = {})
    @field_name = field_name
    @attachment = attachment
    @options = options || {}
    @error = nil
  end

  def valid?
    @valid ||= validate_and_prepare_image
  end

  private

    def validate_and_prepare_image
      # skip validation if it provided as a Hash
      return true if attachment.is_a?(Hash) && attachment.key?(:io)

      imgfile = attachment.tempfile
      image = MiniMagick::Image.open(imgfile.path)

      return false unless image_valid?(image)

      # replace the initially uploaded image
      apply_actions(image)
      imgfile.rewind
      image.write(imgfile)

      change_original_filename(image)

      true
    rescue MiniMagick::Error, MiniMagick::Invalid
      self.error = 'is invalid'
      false
    end

    def error=(error)
      @attachment = nil
      @error = error
    end

    def image_valid?(image)
      validate_image(image) && validate_format(image) && validate_size(image) && validate_dimensions(image)
    end

    def validate_image(image)
      valid_img = image.valid?
      self.error = 'is invalid' unless valid_img
      valid_img
    end

    def validate_format(image)
      valid_format =
        case image.type
        when 'JPEG' then attachment.content_type.in?(%w[image/jpg image/jpeg])
        when 'PNG' then attachment.content_type == 'image/png'
        else false
        end

      self.error = 'has unsupported format' unless valid_format
      valid_format
    end

    def validate_size(image)
      valid_size = image.size < MAX_SIZE

      self.error = 'has too big size' unless valid_size

      valid_size
    end

    def validate_dimensions(image)
      valid_dimensions = image.width <= MAX_WIDHT && image.height <= MAX_HEIGHT

      self.error = 'exceeds maximum pixel dimensions' unless valid_dimensions

      valid_dimensions
    end

    def apply_actions(image)
      process_actions = prepare_actions(image)
      return if process_actions.empty?

      image.combine_options do |img|
        process_actions.map do |action, params|
          if params
            img.public_send(action, params)
          else
            img.public_send(action)
          end
        end
      end
    end

    def prepare_actions(image)
      process_actions = {}
      process_actions[:strip] = nil if image.type == 'JPEG'
      process_actions[:resize] = options[:resize] if options.key?(:resize)
      process_actions
    end

    def change_original_filename(image)
      if attachment.class.method_defined?(:original_filename=) # some tests can't change it
        attachment.original_filename = "#{field_name}.#{image.type.downcase}" # image.jpeg
      end
    end
end
