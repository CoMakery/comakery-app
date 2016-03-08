class Views::Projects::Show < Views::Base
  needs :project, :award, :awardable_accounts, :award_data

  def make_pie_chart
    text(<<-JAVASCRIPT.html_safe)
      $(function() { window.pieChart("#award-percentages", {"content": [#{award_data.map { |datum| pie_chart_data_element(datum) }.join(",")}]});});
    JAVASCRIPT
  end

  def pie_chart_data_element(award_datum)
    {"label": award_datum[:name], "value": award_datum[:net_amount]}.to_json
  end

  def content
    if award_data.present?
      content_for :js do
        make_pie_chart
      end
    end

    row {
      column("small-3") {
        text attachment_image_tag(project, :image, class: "project-image")
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
        br
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
        full_row {}
        row {
          column("small-6 centered") {
            if project.tracker
              a(href: project.tracker, target: "_blank", class: "text-link") do
                i(class: "fa fa-tasks")
                text " Project Tasks"
              end
            end
          }
          column("small-6 centered") {
            if project.slack_team_domain
              a(href: "https://#{project.slack_team_domain}.slack.com", target: "_blank", class: "text-link") do
                i(class: "fa fa-slack")
                text " Project Slack Channel"
              end
            end
          }
        }
      }
    }
    row {
      column("small-6") {
        fieldset {
          row {
            column("small-6") {
              span(class: "underline") { text "Award Names" }
            }
            column("small-6") {
              span(class: "underline") { text "Suggested Value" }
            }
          }

          if !policy(project).send_award?
            project.award_types.each do |award_type|
              row {
                column("small-6") {
                  span(award_type.name)
                }
                column("small-6") {
                  text award_type.amount
                }
              }
            end
          else
            form_for [project, award] do |f|
              row(class: "award-types") {
                project.award_types.each do |award_type|
                  row(class: "award-type-row") {
                    column("small-6") {
                      with_errors(project, :account_id) {
                        label {
                          f.radio_button(:award_type_id, award_type.to_param)
                          span(award_type.name, class: "margin-small")
                        }
                      }
                    }
                    column("small-6") {
                      text award_type.amount
                    }
                  }
                end
                row {
                  column("small-8") {
                    label {
                      text "User"
                      options = capture do
                        options_for_select([[nil, nil]].concat(awardable_accounts))
                      end
                      select_tag "award[slack_user_id]", options, html: {id: "award_slack_user_id"}
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
                  f.submit("Send Award", class: buttonish << "right")
                }
              }
            end
          end
        }
      }
      column("small-6") {
        div(id: "award-percentages", 'data-pie-chart': '')
        div {
          a(href: project_awards_path(project), class: "text-link") { text "Award History >>" }
        }
      }
    }
    full_row {
      a("Back", class: buttonish << "margin-small", href: projects_path)
    }
  end
end
