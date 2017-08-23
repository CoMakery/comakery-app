class Views::Shared::AwardProgressBar < Views::Base
  include Pundit
  needs :project, :current_auth

  def content
    return unless current_auth.present? && policy(project).team_member?
    div(class: 'meter-box') do
      div(class: 'meter-text') do
        if current_auth.percent_unpaid(project) <= 20
          complete { br }
          incomplete do
            h4 project.payment_description
            meter_text_balances
          end
        else
          complete do
            h4 project.payment_description
            meter_text_balances
          end
          incomplete {}
        end
      end

      if current_auth.percent_unpaid(project) >= 20
        meter(left: percent_mine_pretty)
      else
        meter(right: percent_mine_pretty)
      end

      div(class: 'meter-text') do
        div(class: 'end-text') do
          text 'Contributor Pool Balance'
          br
          text "#{project.payment_description} #{project.total_awarded_pretty}"
          if project.revenue_share?
            br
            text project.total_revenue_shared_unpaid_pretty.to_s
          end
        end
      end
    end
  end

  def meter_text_balances
    text 'My Balance'
    br
    my_share
    if project.revenue_share?
      br
      my_balance
    end
  end

  def my_share
    span(class: ' my-share ') do
      text "#{project.payment_description} #{current_auth.total_awards_remaining_pretty(project)}"
    end
  end

  def my_balance
    span(class: ' my-balance ') do
      text current_auth.total_revenue_unpaid_remaining_pretty(project).to_s
    end
  end

  def meter(left: ' ', right: ' ')
    div(class: ' meter ') do
      span(class: ' complete ', style: "width: #{current_auth.percentage_of_unpaid_pretty(project)}") do
        text left
      end
      span(class: ' incomplete ') { text right }
    end
  end

  def percent_mine_pretty
    "#{current_auth.percentage_of_unpaid_pretty(project)} Mine"
  end

  def complete
    div(class: ' complete-text ', style: "width: #{current_auth.percentage_of_unpaid_pretty(project)}") { yield }
  end

  def incomplete
    div(class: ' incomplete-text ') { yield }
  end
end
