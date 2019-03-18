class Views::Projects::Show < Views::Projects::Base
  needs :project, :award, :awardable_types, :can_award, :props

  def content
    text react_component 'Project', props
    # render partial: 'shared/project_header'

    # div(class: 'project-head content') do
    #   render partial: 'projects/description'
    # end

    div(class: 'project-body content-box') do
      row do
        column('large-6 medium-12', id: 'awards') do
          render partial: 'projects/award_send'
        end
      end
    end
  end
end
