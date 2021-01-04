class PopulateMissionsImages < ActiveRecord::DataMigration
  def up
    Mission.find_each do |mission|
      %i[logo image whitelabel_logo whitelabel_logo_dark whitelabel_favicon].each do |image_field|
        attachment_id = mission.public_send("#{image_field}_id")

        next if attachment_id.blank?

        attachment = Refile.store.get(attachment_id).download
        mission.public_send(image_field).attach(
          io: attachment,
          filename: mission.public_send("#{image_field}_filename")
        )
      end
    end
  end

  def down; end
end
