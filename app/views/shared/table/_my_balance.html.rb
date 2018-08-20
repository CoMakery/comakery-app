class Views::Shared::Table::MyBalance < Views::Projects::Base
  needs :project, :current_account_deco

  def content
    if project.revenue_share?
      column('large-4 medium-12 summary float-left my-balance') do
        row(class: 'money') do
          h3 'My Balance'
        end
        row(class: 'total-revenue table-box') do
          table do
            tr do
              td(class: 'token-numbers') { text '' }
              td do
                span(class: 'token-numbers total-awards-remaining') do
                  text current_account_deco.total_awards_remaining_pretty(project)
                end
                span { text ' Unpaid Revenue Shares' }
              end
            end
            tr do
              td(class: 'token-numbers') { text '×' }
              td do
                span(class: 'token-numbers revenue-per-share') { text project.revenue_per_share_pretty }
                span { text ' Current Share Value' }
              end
            end
            tr(class: 'money') do
              td(class: 'token-numbers') { text '=' }
              td do
                span(class: 'token-numbers total-revenue-unpaid') { text current_account_deco.total_revenue_unpaid_remaining_pretty(project) }
                span { text ' My Balance' }
              end
            end
          end
        end
      end
    end
  end
end
