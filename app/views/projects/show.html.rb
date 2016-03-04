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
          column("small-3") {
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
          column("small-5") {
            p {
              text "Owner: "
              b "#{project.owner_slack_user_name}"
            }
          }
        }
        full_row {
          if project.tracker
            a(href: project.tracker) do
              i(class:"fa fa-tasks")
              text " Project Tasks"
            end
          end
        }
      }
    }
    row {
      column("small-6") {
        fieldset {
          row {
            column("small-6") {
              span(class: "underline") { text "Reward Names" }
            }
            column("small-6") {
              span(class: "underline") { text "Suggested Value" }
            }
          }

          if !policy(project).send_reward?
            project.reward_types.each do |reward_type|
              row {
                column("small-6") {
                  span(reward_type.name)
                }
                column("small-6") {
                  text reward_type.amount
                }
              }
            end
          else
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
                    label {
                      text "User"
                      options = capture do
                        options_for_select([[nil, nil]].concat(rewardable_accounts))
                      end
                      select_tag "reward[slack_user_id]", options, html: {id: "reward_slack_user_id"}
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
