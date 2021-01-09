class PopulateProjectsImages < ActiveRecord::DataMigration
  def up
    Project.find_each do |project|
      %i[image square_image panoramic_image].each do |image_field|
        attachment_id = project.public_send("#{image_field}_id")

        next if attachment_id.blank?

        begin
          attachment = Refile.store.get(attachment_id).download
          project.public_send(image_field).attach(
            io: attachment,
            filename: project.public_send("#{image_field}_filename") || 'project_image'
          )
        rescue StandardError
          next
        end
      end
    end
  end

  def down; end
end
