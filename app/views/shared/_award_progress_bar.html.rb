class Views::Shared::AwardProgressBar < Views::Base
  include Pundit
  needs :project

  def content
    div(class: 'meter-box') do
      div(class: 'meter-text') do
        column('small-6', style: 'padding-left: 0') do
          text project.tokens_awarded_with_symbol
        end
        column('small-6', style: 'text-align: right; padding-right: 0') do
          text project.total_awarded_pretty
          text ' of '
          text project.maximum_tokens_pretty
        end
      end

      if project.percent_awarded >= 15
        meter(left: project.percent_awarded_pretty)
      else
        meter(right: project.percent_awarded_pretty)
      end
    end
  end

  def meter(left: ' ', right: ' ')
    div(class: ' meter ') do
      span(class: ' complete ', style: "width: #{project.percent_awarded_pretty};") do
        text left
      end
      span(class: ' incomplete ') { text right }
    end
  end
end
