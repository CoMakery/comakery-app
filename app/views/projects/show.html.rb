class Views::Projects::Show < Views::Base
  needs :project, :award, :awardable_accounts, :award_data

  def make_pie_chart
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        window.pieChart("#award-percentages", {"content": [#{award_data[:contributions].map { |datum| pie_chart_data_element(datum) }.join(",")}]});
        window.stackedBarChart("#contributions-chart", #{award_data[:contributions_by_day].to_json});
      });
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

    row(class:"project-header") {
      column("small-12") {
        h1 project.title
        p {
          text "by "
          strong project.slack_team_name
          if policy(project).edit?
            a(class: "edit", href: edit_project_path(project)) {
              i(class: "fa fa-pencil") {}
              text " Edit Project"
            }
          end
        }
      }
    }
    row {
      column("small-6") {
        # text attachment_image_tag(project, :image, class: "project-image")

        div(class: "project-image", style: "background-image: url(#{attachment_url(project, :image)})") {}
      }
      column("small-6") {
        full_row {
          p project.description
        }
        row(class:"project-settings") {
          column("small-6") {
            text "Owner: "
            b "#{project.owner_slack_user_name}"
          }
          column("small-6") {
            text "Visibility: "
            b "#{project.public? ? "Public" : "Private"}"
          }
        }
        row(class:"project-tasks") {
          if project.tracker
            column("small-5") {
              a(href: project.tracker, target: "_blank", class: "text-link") do
                i(class: "fa fa-tasks")
                text " Project Tasks"
              end
            }
          end
          if project.slack_team_domain
            column("small-7") {
              a(href: "https://#{project.slack_team_domain}.slack.com", target: "_blank", class: "text-link") do
                i(class: "fa fa-slack")
                text " Project Slack Channel"
              end
            }
          end
        }
      }
    }
    row(class:"project-body") {
      column("small-5") {
        if !policy(project).send_award?
          project.award_types.each do |award_type|
            row {
              column("small-12") {
                span(award_type.name)
                text " (#{award_type.amount})"
              }
            }
          end
        else
          form_for [project, award] do |f|
            row() {
              div(class: "award-send") {
                h3 "Send awards"
                project.award_types.each do |award_type|
                  row(class: "award-type-row") {
                    column("small-12") {
                      with_errors(project, :account_id) {
                        label {
                          f.radio_button(:award_type_id, award_type.to_param)
                          span(award_type.name)
                          text " (#{award_type.amount}) "
                        }
                      }
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
                  column("small-8") {}
                  column("small-4") {
                    f.submit("Send Award", class: buttonish(:tiny, :round))
                  }
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
          if award_data[:award_amounts][:my_project_coins]
            column("small-6", class: "centered") {
              div(class: "centered font-large") { text award_data[:award_amounts][:my_project_coins] }
              div(class: "centered") { text "My Project Coins" }
            }
          end
          column("small-6") {
            div(class: "centered font-large") { text award_data[:award_amounts][:total_coins_issued] }
            div(class: "centered") { text "Total Coins Issued" }
          }
        }

        br

        row { column("small-12", class: "underlined-header") { text "Contributions" } }

        full_row {
          div(id: "contributions-chart")
        }

        row {
          column("small-6") {
            award_data[:contributions].each do |contributor|
              div {
                div(class: "right") { text contributor[:net_amount] }
                span contributor[:name]
              }
            end
          }
          column("small-6") { div(id: "award-percentages") }
        }

        div {
          a(href: project_awards_path(project), class: "text-link") { text "Award History »" }
        }
      }
    }
    full_row {
      a("Back", class: buttonish << "margin-small", href: projects_path)
    }
  end
end
