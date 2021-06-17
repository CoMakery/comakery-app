# Resize options: https://legacy.imagemagick.org/Usage/resize/#noaspect
class ImagePreparer
  MAX_WIDHT = 4096
  MAX_HEIGHT = 4096
  MAX_SIZE = 2.megabytes

  attr_reader :record, :params, :options

  def initialize(record, params, options = {})
    @record = record
    @params = params
    @options = options
  end

  def valid?
    @valid ||= attachments.all? { |attr, attachment| prepare_image(attr, attachment) }
  end

  private

    def prepare_image(attr, attachment)
      imgfile = attachment.tempfile
      image = MiniMagick::Image.open(imgfile.path)

      return false unless image_valid?(attr, attachment, image)

      # replace the initially uploaded image
      apply_actions(image, @options[attr.to_sym])
      imgfile.rewind
      image.write(imgfile)

      change_original_filename(attr, attachment, image)

      true
    rescue MiniMagick::Error, MiniMagick::Invalid
      record.errors.add(attr.to_sym, 'is invalid')
      false
    end

    def image_valid?(attr, attachment, image)
      validate_image(attr, attachment, image) && validate_format(attr, attachment, image) && validate_size(attr, attachment, image) && validate_dimensions(attr, attachment, image)
    end

    def validate_image(attr, _attachment, image)
      valid_img = image.valid?
      record.errors.add(attr.to_sym, 'is invalid') unless valid_img
      valid_img
    end

    def validate_format(attr, attachment, image)
      valid_format =
        case image.type
        when 'JPEG' then attachment.content_type.in?(%w[image/jpg image/jpeg])
        when 'PNG' then attachment.content_type == 'image/png'
        else false
        end

      record.errors.add(attr.to_sym, 'has unsupported format') unless valid_format
      valid_format
    end

    def validate_size(attr, _attachment, image)
      valid_size = image.size < MAX_SIZE

      record.errors.add(attr.to_sym, 'has too big size') unless valid_size

      valid_size
    end

    def validate_dimensions(attr, _attachment, image)
      valid_dimensions = image.width <= MAX_WIDHT && image.height <= MAX_HEIGHT

      record.errors.add(attr.to_sym, 'exceeds maximum pixel dimensions') unless valid_dimensions

      valid_dimensions
    end

    def apply_actions(image, options)
      process_actions = {}
      process_actions[:strip] = nil if image.type == 'JPEG'
      process_actions[:resize] = options[:resize] if options.key?(:resize)

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

    def attachments
      params.to_h.slice(*attachment_keys)
    end

    def attachment_keys
      record.attachment_reflections.keys
    end

    def change_original_filename(attr, attachment, image)
      if attachment.class.method_defined?(:original_filename=) # some tests can't change it
        attachment.original_filename = "#{record.model_name.param_key}_#{attr}.#{image.type.downcase}" # account_image.jpeg
      end
    end
end
