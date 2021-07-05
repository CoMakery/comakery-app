class DeleteInvalidImages < ActiveRecord::DataMigration
  def up
    process_project_images
    process_account_images
    process_mission_images
    process_token_images
    process_award_images
    process_award_type_images
  end

  def process_project_images
    Project.find_each do |project|
      purge_if_invalid(project.image)
      purge_if_invalid(project.square_image)
      purge_if_invalid(project.panoramic_image)
    end
  end

  def process_account_images
    Account.find_each do |account|
      purge_if_invalid(account.image)
    end
  end

  def process_mission_images
    Mission.find_each do |mission|
      purge_if_invalid(mission.logo)
      purge_if_invalid(mission.image)
      purge_if_invalid(mission.whitelabel_logo)
      purge_if_invalid(mission.whitelabel_logo_dark)
      purge_if_invalid(mission.whitelabel_favicon)
    end
  end

  def process_token_images
    Token.find_each do |token|
      purge_if_invalid(token.logo_image)
    end
  end

  def process_award_images
    Award.find_each do |award|
      purge_if_invalid(award.image)
    end
  end

  def process_award_type_images
    AwardType.find_each do |award_type|
      purge_if_invalid(award_type.diagram)
    end
  end

  def valid?(imgfile)
    image = MiniMagick::Image.open(imgfile.path)

    return false unless image.valid?
    return false if image.size >= 2.megabytes
    return false if image.width > 4096 || image.height > 4096

    true
  rescue MiniMagick::Error, MiniMagick::Invalid
    false
  end

  def purge_if_invalid(image_field)
    image_field.purge if purge_image?(image_field)
  end

  def purge_image?(image_field)
    return false unless image_field.attached?

    !image_field.open { |imgfile| valid?(imgfile) }
  end
end
