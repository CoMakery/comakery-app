class Views::Projects::Base < Views::Base

  def projects_header(section_heading)
    row {
      column("small-12 medium-10") {
        h2 section_heading
      }
      column("small-12 medium-2") {
        a("New Project", class: buttonish("float-right"), href: new_project_path) if policy(Project).new?
      }
    }
  end

  def projects_block(projects, project_contributors)
    row {
      projects.each_slice(3) do |left_project, middle_project, right_project|
        column("small-12 medium-6 large-4") {
          project_block(left_project, project_contributors[left_project])
        }
        column("small-12 medium-6 large-4") {
          project_block(middle_project, project_contributors[middle_project]) if middle_project
        }
        column("small-12 medium-6 large-4") {
          project_block(right_project, project_contributors[right_project]) if right_project
        }
      end
    }
  end

  def project_block(project, contributors)
    row(class: "project#{project.slack_team_id == current_account&.slack_auth&.slack_team_id ? " project-highlighted" : ""}", id: "project-#{project.to_param}") {
      a(href: project_path(project)) {
        div(class: "sixteen-nine") {
          div(class: "content") {
            img(src: attachment_url(project, :image), class: "image-block")
          }
        }
      }
      div(class: "info") {
        div(class: "text-overlay") {
          h5 {
            a(project.title, href: project_path(project), class: "project-link")
          }
          a(href: project_path(project)) {
            i project.slack_team_name
          }
        }
        a(href: project_path(project)) {
          img(src: project.slack_team_image_132_url, class: "icon")
        }
        if project.last_award_created_at
          p(class: "project-last-award font-tiny") { text "active #{time_ago_in_words(project.last_award_created_at)} ago" }
          p(class:"description") { text project.description.try(:truncate, 90) }
        else
          p(class: "description no-last-award") { text project.description.try(:truncate, 90) }
        end

        div(class: "contributors") {
          # this can go away when project owners become auths instead of accounts
          owner_auth = project.owner_account.authentications.find_by(slack_team_id: project.slack_team_id)

          ([owner_auth].compact + Array.wrap(contributors)).uniq{|auth|auth.id}.each do |contributor|
            tooltip = contributor == owner_auth ?
              "#{contributor.display_name} - Project Owner#{contributor.respond_to?(:total_awarded) ? " - #{contributor.total_awarded.to_i} coins" : ""}" :
              "#{contributor.display_name} - #{contributor.total_awarded.to_i} coins"
            tooltip(tooltip) {
              img(src: contributor.slack_icon, class: "contributor avatar-img")
            }
          end
        }
      }
    }
  end
end
