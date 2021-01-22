class ValidateAttachments < ActiveRecord::DataMigration
  IMAGE_TYPES = %w[image/png image/jpg image/jpeg].freeze
  MODEL_AND_FIELDS = {
    account: %w[image],
    mission: %w[logo image whitelabel_logo whitelabel_logo_dark whitelabel_favicon],
    project: %w[image square_image panoramic_image],
    token: %w[logo_image]
  }.freeze

  def up
    MODEL_AND_FIELDS.stringify_keys.each do |model, fields|
      model.capitalize.constantize.find_each do |m|
        fields.each do |field|
          m.send(field).purge if m.send(field).attached? && invalid(field, m)
        end
      end
    end
  end

  def invalid(field, model)
    IMAGE_TYPES.exclude?(model.send(field).blob.content_type) || model.send(field).blob.byte_size > 10.megabytes
  end
end
