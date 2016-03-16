class Views::Projects::Base < Views::Base

  def projects_header(slack_auth)
    full_row {
      column("small-1") { img src: slack_auth.slack_team_image_34_url, class: "project-icon" }
      column("small-9") {
        h2 "#{slack_auth.slack_team_name} Projects"
      }
      column("small-2") {
        a("New Project", class: buttonish(:button, :radius, :tiny), href: new_project_path) if policy(Project).new?
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
    row(class: "project#{project.slack_team_id == current_account&.slack_auth&.slack_team_id ? " project-highlighted" : ""}", id: "project-#{project.to_param}") {
      a(href: project_path(project), class: "image-block", style: "background-image: url(#{attachment_url(project, :image)})") {}
      div(class: "description") {
        div(class:"text-overlay") {
          h5 {
            a(project.title, href: project_path(project), class: "project-link")
          }
          i project.slack_team_name
        }
        img(src: project.slack_team_image_34_url, class: "icon")
        if project.last_award_created_at
          div(class: "project-last-award font-tiny") { text "last activity #{time_ago_in_words(project.last_award_created_at)} ago" }
        end
        p project.description.try(:truncate, 120)
      }
    }
  end
end
