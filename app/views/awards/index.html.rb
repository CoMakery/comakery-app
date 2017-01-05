class Views::Awards::Index < Views::Base
  needs :project, :awards

  def content
    render partial: 'shared/project_header'
    column {
      h3 "Award History"

      render partial: 'awards/activity'

      render partial: "shared/awards",
             locals: {project: project, awards: awards, show_recipient: true}
    }
  end
end
