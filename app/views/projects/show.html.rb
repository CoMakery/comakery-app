class Views::Projects::Show < Views::Base
  needs :project, :reward, :rewardable_accounts

  def content
    row {
      column("small-3") {
        img(src: attachment_url(project, :image), class: "project-image")
      }
      column("small-9") {
        row {
          column("small-9") {
            h1 project.title
          }
          column("small-3") {
            a "Edit", class: buttonish, href: edit_project_path(project) if policy(project).edit?
          }
        }
        p project.description
        a "Project Tasks »", class: buttonish, href: project.tracker if project.tracker
      }
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
    form_for [project, reward] do |f|
      row(class: "reward-types") {
        project.reward_types.each do |reward_type|
          row(class: "reward-type-row") {
            column("small-4") {
              with_errors(project, :account_id) {
                label {
                  f.radio_button(:reward_type_id, reward_type.to_param)
                  span(reward_type.name, class: "margin-small")
                }
              }
            }
            column("small-4") {
              text reward_type.amount
            }
            column("small-4") {
            }
          }
        end
        row {
          column("small-4") {
            with_errors(project, :account_id) {
              label {
                text "User"
                f.select(:account_id, [[nil, nil]].concat(rewardable_accounts.map { |a| [a.name, a.id] }))
              }
            }
          }
        }
        row {
          column("small-4") {
            with_errors(project, :description) {
              label {
                text "Description"
                f.text_area(:description)
              }
            }
          }
        }
        row {
          column("small-4") {
            f.submit("Send Reward", class: buttonish)
          }
        }
      }
    end
    full_row {
      p "Visibility: #{project.public? ? "Public" : "Private"}"
    }
    full_row {
      a("Back", class: buttonish << "margin-small", href: projects_path)
    }
  end
end
