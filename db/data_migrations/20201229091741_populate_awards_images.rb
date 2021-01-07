class PopulateAwardsImages < ActiveRecord::DataMigration
  def up
    Award.find_each do |award|
      %i[image submission_image].each do |image_field|
        attachment_id = award.public_send("#{image_field}_id")

        next if attachment_id.blank?

        begin
          attachment = Refile.store.get(attachment_id).download
          award.public_send(image_field).attach(
            io: attachment,
            filename: award.public_send("#{image_field}_filename") || 'award_image'
          )
        rescue StandardError
          next
        end
      end
    end
  end

  def down; end
end
