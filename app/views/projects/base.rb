class Views::Projects::Base < Views::Base
  def projects_block(projects)
    projects.each_slice(2) do |left_project, right_project|
      row {
        column("small-6") {
          project_block(left_project)
        }
        column("small-6") {
          project_block(right_project) if right_project
        }
      }
    end
  end

  def project_block(project)
    row(class: "project", id: "project-#{project.to_param}") {
      column("small-4") {
        div(class: "image-block") {
          text attachment_image_tag(project, :image, :fit, 150, 150, class: "margin-small")
        }
      }
      column("small-8") {
        div(class: "margin-small") {
          b { a(project.title, href: project_path(project)) }
          div project.description.try(:truncate, 35)
          i project.slack_team_name
        }
      }
    }
  end
end
