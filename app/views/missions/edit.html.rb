class Views::Missions::Edit < Views::Base
  needs :mission

  def content
    text react_component 'Mission',
      id: mission.id,
      name: mission.name || '',
      subtitle: mission.subtitle || '',
      description: mission.description || '',
      logo_preview: mission.logo.present? ? Refile.attachment_url(mission, :logo, :fill, 150, 100) : nil,
      image_preview: mission.image.present? ? Refile.attachment_url(mission, :image, :fill, 100, 100) : nil
  end
end
