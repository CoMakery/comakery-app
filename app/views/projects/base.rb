class Views::Projects::Base < Views::Base

  def projects_header(section_heading)
    row {
      column("small-10") {
        h2 section_heading
      }
      column("small-2") {
        a("New Project", class: buttonish("float-right"), href: new_project_path) if policy(Project).new?
      }
    }
  end

  def projects_block(projects)
    projects.each_slice(3) do |left_project, middle_project, right_project|
      row {
        column("small-12 medium-6 large-4") {
          project_block(left_project)
        }
        column("small-12 medium-6 large-4") {
          project_block(middle_project) if middle_project
        }
        column("small-12 medium-6 large-4") {
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
        img(src: project.slack_team_image_132_url, class: "icon")
        if project.last_award_created_at
          p(class: "project-last-award font-tiny") { text "active #{time_ago_in_words(project.last_award_created_at)} ago" }
        end
        p project.description.try(:truncate, 90)
      }
    }
  end
end
