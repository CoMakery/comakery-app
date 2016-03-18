class Views::Projects::Show < Views::Base
  needs :project, :award, :awardable_accounts, :awardable_types, :award_data, :can_award

  def make_charts
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
        make_charts
      end
    end

    row(class: "project-header") {
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
        div(class: "project-image", style: "background-image: url(#{attachment_url(project, :image)})") {}
      }
      column("small-6") {
        full_row {
          p project.description
        }
        row(class: "project-settings") {
          column("small-6") {
            text "Owner: "
            b "#{project.owner_slack_user_name}"
          }
          column("small-6") {
            text "Visibility: "
            b "#{project.public? ? "Public" : "Private"}"
          }
        }
        row(class: "project-tasks") {
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
    row(class: "project-body") {
      column("small-5 award-send") {
        render partial: "award_send"
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
          column("small-4") {
            award_data[:contributions].each do |contributor|
              div {
                div(class: "float-right") { text contributor[:net_amount] }
                span contributor[:name]
              }
            end
          }
          column("small-8") { div(id: "award-percentages") }
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
