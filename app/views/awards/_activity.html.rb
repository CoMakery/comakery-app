class Views::Awards::Activity < Views::Base
  needs :project

  def content
    column {
      div {
        h3 "#{project.payment_description} Awarded"
        br

        if project.awards_for_chart.present?
          p {
            div(id: 'contributions-chart')
          }
          content_for :js do
            make_charts
          end
        end
      }
    }
  end

  def make_charts
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        window.stackedBarChart("#contributions-chart", #{project.awards_for_chart.to_json});
      });
    JAVASCRIPT
  end
end
