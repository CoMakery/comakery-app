class Views::Projects::Base < Views::Base

  def projects_header(slack_auth)
    full_row {
      column("small-1") { img src: slack_auth.slack_team_image_34_url, class: "project-icon" }
      column("small-7") {
        h2 "#{slack_auth.slack_team_name} Projects"
      }
      column("small-4") {
        a("New Project", class: buttonish(:button, :round, :tiny), href: new_project_path) if policy(Project).new?
      }
    }
  end

  def projects_block(projects)
    projects.each_slice(3) do |left_project, middle_project, right_project|
      row {
        column("small-4") {
          project_block(left_project)
        }
        column("small-4") {
          project_block(middle_project) if middle_project
        }
        column("small-4") {
          project_block(right_project) if right_project
        }
      }
    end
  end

  def project_block(project)
    row(class: "project", id: "project-#{project.to_param}") {
      column("small-12") {
        div(class: "image-block") {
          text attachment_image_tag(project, :image)
        }
        h5 { a(project.title, href: project_path(project)) }
        i project.slack_team_name
        div project.description.try(:truncate, 35)
      }
    }
  end
end
