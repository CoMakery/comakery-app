class Views::Shared::AwardProgressBar < Views::Base
  needs :project, :award_data, :current_auth

  def content
    div(class: 'meter-box') {
      div(class: 'meter-text') {
        div(class: 'complete-text', style: "width: #{current_auth.percentage_of_unpaid_pretty(project)}") {}
        div(class: 'incomplete-text') {
          text " "
        }
        div(class: 'end-text') {
          text "Project #{project.outstanding_award_description}"
          br
          text "#{project.total_awarded_pretty}"
        }
      }

      div(class: 'meter') {
        div(class: 'complete', style: "width: #{current_auth.percentage_of_unpaid_pretty(project)}") { text " " }
        div(class: 'incomplete') { text " " }
      }

      div(class: 'meter-text') {
        if true # current_auth.percent_unpaid(project) <= 50
          div(class: 'complete-text', style: "width: #{current_auth.percentage_of_unpaid_pretty(project)}") {}
          div(class: 'incomplete-text') {
            text "My #{project.outstanding_award_description} (#{current_auth.percentage_of_unpaid_pretty(project)})"
            br
            text "#{current_auth.total_awards_remaining_pretty(project)}"
          }
        else
          div(class: 'complete-text', style: "width: #{current_auth.percentage_of_unpaid_pretty(project)}") {
            text "My #{project.outstanding_award_description} (#{current_auth.percentage_of_unpaid_pretty(project)})"
            br
            text "#{current_auth.total_awards_remaining_pretty(project)}"

          }
          div(class: 'incomplete-text') {
            text " "
          }
        end

        div(class: 'end-text') {
          text " "
        }
      }
    }
  end
end