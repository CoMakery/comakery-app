class Views::Projects::Show < Views::Base
  needs :project, :award, :awardable_accounts, :award_data

  def make_pie_chart
    text(<<-JAVASCRIPT.html_safe)
      $(function() { window.pieChart("#award-percentages", {"content": [#{award_data[:contributions].map { |datum| pie_chart_data_element(datum) }.join(",")}]});});
    JAVASCRIPT
  end

  def pie_chart_data_element(award_datum)
    {"label": award_datum[:name], "value": award_datum[:net_amount]}.to_json
  end

  def content
    if award_data[:contributions].present?
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
        row {
          column("small-6") {
            div(class: "underlined-header") { text "Award Names" }
          }
          column("small-6") {
            div(class: "underlined-header") { text "Suggested Value" }
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
              row {
                column("small-6") {}
                column("small-6") {
                  f.submit("Send Award", class: buttonish)
                }
              }
            }
          end
        end
      }
      column("small-6") {
        row { column("small-12", class: "underlined-header") { text "Awards" } }

        br

        row {
          column("small-6", class: "centered") {
            div(class: "centered font-large") { text award_data[:award_amounts][:my_project_coins] }
            div(class: "centered") { text "My Project Coins" }
          }
          column("small-6") {
            div(class: "centered font-large") { text award_data[:award_amounts][:total_coins_issued] }
            div(class: "centered") { text "Total Coins Issued" }
          }
        }

        br

        row { column("small-12", class: "underlined-header") { text "Contributions" } }

        row {
          column("small-6") {
            award_data[:contributions].each do |contributor|
              div {
                div(class: "right") { text contributor[:net_amount] }
                span contributor[:name]
              }
            end
          }
          column("small-6") { div(id: "award-percentages", 'data-pie-chart': '') }
        }

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
