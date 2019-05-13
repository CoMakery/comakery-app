namespace :migration do
  task update_project_images: [:environment] do
    Project.where(square_image_id: nil).where.not(image_id: nil).find_each do |project|
      project.update square_image_id: Refile.store.upload(
        begin
          File.open(MiniMagick::Image.read(project.image.read).resize('1200x800!').path)
        rescue SystemCallError => e
          puts "Rescued from SystemCallError: #{e.message}"
          next
        end
      ).id
    end

    Project.where(panoramic_image_id: nil).where.not(image_id: nil).find_each do |project|
      project.update panoramic_image_id: Refile.store.upload(
        begin
          File.open(MiniMagick::Image.read(project.image.read).resize('1500x300!').path)
        rescue SystemCallError => e
          puts "Rescued from SystemCallError: #{e.message}"
          next
        end
      ).id
    end
  end
end
