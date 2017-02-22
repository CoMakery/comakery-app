class Views::Contributors::Index < Views::Projects::Base
  needs :project, :award_data

  def content
    render partial: 'shared/project_header'
    column {
      full_row {
        if award_data[:contributions].present?
          p {
            h4 "#{project.payment_description}"
            div(id: "award-percentages", class: "royalty-pie") {}
          }
          content_for :js do
            make_charts
          end
        end
      }

      full_row {
        if award_data[:contributions_summary].present?
          div(class: "table-scroll table-box .contributors") {
            table(class: "table-scroll", style: "width: 100%") {
              tr(class: "header-row") {
                th "Contributors"
                th { text "Current #{project.payment_description.singularize} Holdings" }
                th { text "Current Value" } if project.revenue_share?
                th { text "Lifetime #{project.payment_description} Earned" }
                th { text "Lifetime Paid" } if project.revenue_share?
              }
              project.contributors_by_award_amount.each do |contributor_auth|

                tr(class: "award-row") {
                  td(class: "contributor") {
                    img(src: contributor_auth.slack_icon, class: "icon avatar-img")
                    div(class: "margin-small margin-collapse inline-block") { text contributor_auth.display_name }
                  }
                  td(class: "award-holdings financial") {
                    span(class: "margin-small") {
                      text text contributor_auth.total_awards_remaining_pretty(project)
                    }
                  }

                  if project.revenue_share?
                    td(class: "holdings-value financial") {
                      span(class: "margin-small") {
                        text contributor_auth.total_revenue_unpaid_remaining_pretty(project)
                      }
                    }
                  end
                  td(class: "awards-earned financial") {
                    span(class: "margin-small") {
                      text contributor_auth.total_awards_earned_pretty(project)
                    }
                  }
                  if project.revenue_share?
                    td(class: "paid hidden financial") {
                      span(class: "margin-small") {
                        text contributor_auth.total_revenue_paid_pretty(project)
                      }
                    }
                  end
                }
              end
            }
          }
        end
      }
    }
  end


  def make_charts
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        window.pieChart("#award-percentages", {"content": #{pie_chart_data}});
      });
    JAVASCRIPT
  end

  def pie_chart_data
    award_data[:contributions_summary_pie_chart].map do |award|
      {label: award[:name], value: award[:net_amount]}
    end.to_json
  end
end