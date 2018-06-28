class Views::Shared::AwardProgressBar < Views::Base
  needs :project, :current_account_deco

  def content
    div(class: 'meter-box') {
      div(class: 'meter-text') {
        column('small-6', style: 'padding-left: 0') {
          text project.tokens_awarded_with_symbol
        }
        column('small-6', style: 'text-align: right; padding-right: 0') {
          text project.total_awarded_pretty
          text ' of '
          text project.maximum_tokens_pretty
        }
      }

      if project.percent_awarded >= 15
        meter(left: project.percent_awarded_pretty)
      else
        meter(right: project.percent_awarded_pretty)
      end
    }
  end

  def meter(left: ' ', right: ' ')
    div(class: ' meter ') {
      span(class: ' complete ', style: "width: #{project.percent_awarded_pretty};") {
        text left
      }
      span(class: ' incomplete ') { text right }
    }
  end
end
