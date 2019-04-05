namespace :migration do
  task update_project_images: [:environment] do
    Project.where(square_image_id: nil).find_each do |project|
      project.update square_image_id: Refile.store.upload(
        File.open(MiniMagick::Image.read(project.image.read).resize('1200x800!').path)
      ).id
    end

  Project.where(panoramic_image_id: nil).find_each do |project|
    project.update panoramic_image_id: Refile.store.upload(
      File.open(MiniMagick::Image.read(project.image.read).resize('1500x300!').path)
    ).id
  end
  end
end
