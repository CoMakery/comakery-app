class Views::Projects::Show < Views::Base
  needs :project

  def content
    full_row {
      h1 project.title
    }
    full_row {
      text project.description
    }
    full_row {
      text "Visibility: #{project.public? ? "Public" : "Private"}"
    }
    full_row {
      a "Project Tasks »", class: buttonish, href: project.tracker
    }

    row {
      column("small-4") {
        text "Reward Names"
      }
      column("small-4") {
        text "Suggested Value"
      }
      column("small-4") {
      }
    }
    div(class: "reward-types") {
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
      a("Edit", class: buttonish, href: edit_project_path(project)) if policy(project).edit?
      a("Back", class: buttonish, href: projects_path)
    }
  end
end
