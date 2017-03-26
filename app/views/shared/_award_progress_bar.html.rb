class Views::Shared::AwardProgressBar < Views::Base
  needs :project, :award_data, :current_auth

  def content
    return unless current_auth.present?
    div(class: 'meter-box') {
      div(class: 'meter-text') {
        if current_auth.percent_unpaid(project) <= 20
          complete {}
          incomplete { meter_text_balances }
        else
          complete { meter_text_balances }
          incomplete {}
        end
      }

      if current_auth.percent_unpaid(project) >= 20
        meter(left: percent_mine_pretty)
      else
        meter(right: percent_mine_pretty)
      end

      div(class: 'meter-text') {
        div(class: 'end-text') {
          text "Contributor Pool Balance"
          br
          text "#{project.total_awarded_pretty}"
          if project.revenue_share?
            br
            text "#{project.total_revenue_shared_unpaid_pretty}"
          end
        }
      }
    }
  end

  def meter_text_balances
    h4 project.payment_description
    text "My Balance"
    if project.revenue_share?
      br
      my_balance
    end
    br
    my_share
  end

  def my_share
    span(class: 'my-share') {
      text "#{current_auth.total_awards_remaining_pretty(project)} #{project.payment_description}"
    }
  end

  def my_balance
    span(class: 'my-balance') {
      text "#{current_auth.total_revenue_unpaid_remaining_pretty(project)}"
    }
  end

  def meter(left: " ", right: " ")
    div(class: 'meter') {
      span(class: 'complete', style: "width: #{current_auth.percentage_of_unpaid_pretty(project)}") {
        text left
      }
      span(class: 'incomplete') { text right }
    }
  end

  def percent_mine_pretty
    "#{current_auth.percentage_of_unpaid_pretty(project)} Mine"
  end

  def complete
    div(class: 'complete-text', style: "width: #{current_auth.percentage_of_unpaid_pretty(project)}") { yield }
  end

  def incomplete
    div(class: 'incomplete-text') { yield }
  end

end