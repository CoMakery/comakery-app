class Views::Projects::Show < Views::Base
  needs :project

  def content
    row {
      column("small-3") {
        img(src: attachment_url(project, :image), class: "project-image")
      }
      column("small-9") {
        h1 project.title
        p project.description
        a "Project Tasks »", class: buttonish, href: project.tracker
      }
    }

    full_row {
      column("small-4") {
        text "Reward Names"
      }
      column("small-4") {
        text "Suggested Value"
      }
      column("small-4") {
      }
    }
    row(class: "reward-types") {
      project.reward_types.each do |reward_type|
        row(class: "reward-type-row") {
          column("small-4") {
            text reward_type.name
          }
          column("small-4") {
            text reward_type.suggested_amount
          }
          column("small-4") {
          }
        }
      end
    }
    full_row {
      p "Visibility: #{project.public? ? "Public" : "Private"}"
    }
    full_row {
      a("Edit", class: buttonish, href: edit_project_path(project)) if policy(project).edit?
      a("Send Reward", class: buttonish, href: new_project_reward_path(project)) if policy(project).send_reward?
      a("Back", class: buttonish, href: projects_path)
    }
  end
end
