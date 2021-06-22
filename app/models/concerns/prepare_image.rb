module PrepareImage
  extend ActiveSupport::Concern

  class_methods do
    # rubocop:todo Naming/PredicateName
    def has_one_attached_and_prepare_image(name, **options)
      has_one_attached :"#{name}"

      before_validation :add_image_errors

      generated_association_methods.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}=(attachable)
          uploaded_image_errors.delete("#{name}") if uploaded_image_errors.key?("#{name}")
          uploaded_image_options["#{name}"] = #{options}
          attachable = prepare_attached_image("#{name}", attachable)

          attachment_changes["#{name}"] =
            if attachable.nil?
              ActiveStorage::Attached::Changes::DeleteOne.new("#{name}", self)
            else
              ActiveStorage::Attached::Changes::CreateOne.new("#{name}", self, attachable)
            end
        end
      CODE
    end
  end

  def uploaded_image_errors
    @uploaded_image_errors ||= {}
  end

  def uploaded_image_options
    @uploaded_image_options ||= {}
  end

  def prepare_attached_image(field_name, attachable)
    preparer = ImagePreparer.new(field_name, attachable, uploaded_image_options[field_name.to_s])
    uploaded_image_errors[field_name] = preparer.error unless preparer.valid?
    preparer.attachment
  end

  def add_image_errors
    uploaded_image_errors.each do |field_name, error|
      errors.add(field_name, error) if error
    end
  end
end
