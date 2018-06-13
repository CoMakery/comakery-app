class Views::Shared::ProjectAwardProgressBar < Views::Base
  needs :project, :current_account_deco

  def content
    return unless current_account_deco.present? && current_account_deco.same_team_or_owned_project?(project)
    div(class: 'meter-box') {
      div(class: 'meter-text') {
        column('small-6', style: 'padding-left: 0') {
          text 'CAS Token Awarded'
        }
        column('small-6', style: 'text-align: right; padding-right: 0') {
          text current_account_deco.total_awards_remaining_pretty(project)
          text ' of '
          text project.total_awards_outstanding
        }
      }

      if current_account_deco.percent_unpaid(project) >= 20
        meter(left: percent_mine_pretty)
      else
        meter(right: percent_mine_pretty)
      end
    }
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
    span(class: ' my-share ') {
      text "#{project.payment_description} #{current_account_deco.total_awards_remaining_pretty(project)}"
    }
  end

  def my_balance
    span(class: ' my-balance ') {
      text current_account_deco.total_revenue_unpaid_remaining_pretty(project).to_s
    }
  end

  def meter(left: ' ', right: ' ')
    div(class: ' meter ') {
      span(class: ' complete ', style: "width: #{current_account_deco.percentage_of_unpaid_pretty(project)}") {
        text left
      }
      span(class: ' incomplete ') { text right }
    }
  end

  def percent_mine_pretty
    "#{current_account_deco.percentage_of_unpaid_pretty(project)} Mine"
  end

  def complete
    div(class: ' complete-text ', style: "width: #{current_account_deco.percentage_of_unpaid_pretty(project)}") { yield }
  end

  def incomplete
    div(class: ' incomplete-text ') { yield }
  end
end
