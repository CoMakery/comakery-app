class Views::Contributors::Index < Views::Projects::Base
  needs :project, :award_data

  def content
    render partial: 'shared/project_header'
    column {
      full_row {
        if award_data[:contributions].present?
          p {
            h4 "#{project.payment_description} Earned "
            div(id: "award-percentages", class: "royalty-pie") {}
          }
          content_for :js do
            make_charts
          end
        end
      }

      full_row {

          if award_data[:contributions_summary].present?
            div(class: "table-scroll") {
              table(class: "award-rows", style: "width: 100%") {
                tr(class: "header-row") {
                  th "Top Contributors"
                  th(class: "text-align-right") { text "Earned" }
                  th(class: "text-align-right") { text "Paid" }
                  th(class: "text-align-right") { text "Remaining" }
                }
                award_data[:contributions_summary].each do |contributor|
                  tr(class: "award-row") {
                    td(class: "contributor") {
                      img(src: contributor[:avatar], class: "icon avatar-img")
                      div(class: "margin-small margin-collapse inline-block") { text contributor[:name] }
                    }
                    td(class: "earned") {
                      span(class: "float-right margin-small") {
                        text project.currency_denomination
                        text number_with_precision(contributor[:earned], precision: 0, delimiter: ',')
                      }
                    }
                    td(class: "paid") {
                      span(class: "float-right margin-small") {
                        text project.currency_denomination
                        text number_with_precision(contributor[:paid], precision: 0, delimiter: ',')
                      }
                    }
                    td(class: "remaining") {
                      span(class: "float-right margin-small") {
                        text project.currency_denomination
                        text number_with_precision(contributor[:remaining], precision: 0, delimiter: ',')
                      }
                    }
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