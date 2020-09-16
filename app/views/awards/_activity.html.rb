class Views::Awards::Activity < Views::Base
  needs :project

  def content
    column do
      div do
        if project.awards_for_chart.present?
          p do
            div(id: 'contributions-chart')
          end
          content_for :js do
            make_charts
          end
        end
      end
    end
  end

  def make_charts
    text(<<-JAVASCRIPT.html_safe) # rubocop:todo Rails/OutputSafety
      $(function() {
        window.stackedBarChart("#contributions-chart", #{project.awards_for_chart.to_json});
      });
    JAVASCRIPT
  end
end
