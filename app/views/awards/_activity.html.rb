class Views::Awards::Activity < Views::Base
  needs :project, :award_data, :current_auth

  def content
    column do
      div do
        h3 "#{project.payment_description} Awarded"
        br

        if award_data[:contributions].present?
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
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        window.stackedBarChart("#contributions-chart", #{award_data[:contributions_by_day].to_json});
      });
    JAVASCRIPT
  end

  def total_tokens_issued
    award_data[:award_amounts][:total_tokens_issued]
  end

  def percentage_issued
    total_tokens_issued * 100 / project.maximum_tokens.to_f
  end
end
