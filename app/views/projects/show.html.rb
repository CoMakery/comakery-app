class Views::Projects::Show < Views::Projects::Base
  needs :project, :award, :awardable_types, :can_award, :props

  def content
    text react_component 'Project', props
  end
end
