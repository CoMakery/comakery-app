class Views::Missions::Index < Views::Base
  needs :missions

  def content
    text react_component 'MissionsIndex',
      missions: missions
  end
end
