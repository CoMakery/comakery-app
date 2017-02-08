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
              award_data[:contributions_summary].each do |contributor|
                tr(class: "award-row") {
                  td(class: "contributor") {
                    img(src: contributor[:avatar], class: "icon avatar-img")
                    div(class: "margin-small margin-collapse inline-block") { text contributor[:name] }
                  }
                  td(class: "award-holdings") {
                    span(class: "margin-small") {
                      text text number_with_precision(contributor[:earned], precision: 0, delimiter: ',')
                    }
                  }

                  if project.revenue_share?
                    td(class: "holdings-value") {
                      span(class: "margin-small") {
                        text project.shares_to_balance_pretty(contributor[:earned])
                      }
                    }
                  end
                  td(class: "awards-earned") {
                    span(class: "margin-small") {
                      text number_with_precision(contributor[:earned], precision: 0, delimiter: ',')
                    }
                  }
                  if project.revenue_share?
                    td(class: "paid hidden") {
                      span(class: "margin-small") {
                        text project.currency_denomination
                        text 0
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