class PopulateAwardsImages < ActiveRecord::DataMigration
  def up
    Award.find_each do |award|
      if award.image_id.present?
        image = Refile.store.get(award.image_id).download
        award.image.attach(io: image, filename: award.image_filename)
      end

      if award.submission_image_id.present?
        submission_image = Refile.store.get(award.submission_image_id).download
        award.submission_image.attach(
          io: submission_image,
          filename: award.submission_image_filename
        )
      end
    end
  end

  def down; end
end
