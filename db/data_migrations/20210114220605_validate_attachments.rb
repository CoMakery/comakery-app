class ValidateAttachments < ActiveRecord::DataMigration
  IMAGE_TYPES = %w[image/png image/jpg image/jpeg]
  MODEL_AND_FIELDS = {
    account: %w[image],
    mission: %w[logo image whitelabel_logo whitelabel_logo_dark whitelabel_favicon],
    project: %w[image square_image panoramic_image],
    token: %w[log_image]
  }

  def up
    MODEL_AND_FIELDS.each do |model, fields|
      model.constantize.find_each do |m|
        fields.each do |field|
          if m.send(field).attached? && is_valid?(field)
            m.send(field).purge
          end
        end
      end
    end
  end

  def is_valid?(field)
    IMAGE_TYPES.exclude?(m.send(field).blob.content_type) || m.send(field).blob.byte_size > 10.megabytes
  end
end
