class Views::Awards::Index < Views::Base
  needs :project, :awards

  def content
    h1 "Award History"
    render partial: "shared/awards",
      locals: {project: project, awards: awards, show_recipient: true}
    br

    link_to "Back to project", project_path(project), class: buttonish
  end
end
