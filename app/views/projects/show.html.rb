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
        full_row {
          text project.description
        }
        row {
          column("small-4") {
            p {
              text "Visibility: "
              b "#{project.public? ? "Public" : "Private"}"
            }
          }
          column("small-4") {
            p {
              text "Team name: "
              b "#{project.slack_team_name}"
            }
          }
          column("small-4") {
            p {
              text "Project owner: "
              b "#{project.owner_account.name}"
            }
          }
        }
        full_row {
          a "Project Tasks »", class: buttonish, href: project.tracker if project.tracker
        }
      }
    }
    row {
      column("small-6") {
        fieldset {
          row {
            column("small-6") {
              text "Reward Names"
            }
            column("small-6") {
              text "Suggested Value"
            }
          }
          form_for [project, reward] do |f|
            row(class: "reward-types") {
              project.reward_types.each do |reward_type|
                row(class: "reward-type-row") {
                  column("small-6") {
                    with_errors(project, :account_id) {
                      label {
                        f.radio_button(:reward_type_id, reward_type.to_param)
                        span(reward_type.name, class: "margin-small")
                      }
                    }
                  }
                  column("small-6") {
                    text reward_type.amount
                  }
                }
              end
              row {
                column("small-8") {
                  with_errors(project, :account_id) {
                    label {
                      text "User"
                      f.select(:account_id, [[nil, nil]].concat(rewardable_accounts.map { |a| [a.name, a.id] }))
                    }
                  }
                }
              }
              row {
                column("small-8") {
                  with_errors(project, :description) {
                    label {
                      text "Description"
                      f.text_area(:description)
                    }
                  }
                }
              }
              full_row {
                f.submit("Send Reward", class: buttonish << "right")
              }
            }
          end
        }
      }
      column("small-6") {
        a(href: project_rewards_path(project)) { text "Award History >>" }
      }
    }
    full_row {
      a("Back", class: buttonish << "margin-small", href: projects_path)
    }
  end
end
