class Views::Shared::Table::MyBalance < Views::Projects::Base
  needs :project, :current_account_deco

  def content
    if project.revenue_share?
      column('large-4 medium-12 summary float-left my-balance') {
        row(class: 'money') {
          h3 'My Balance'
        }
        row(class: 'total-revenue table-box') {
          table {
            tr {
              td(class: 'token-numbers') { text '' }
              td {
                span(class: 'token-numbers total-awards-remaining') {
                  text current_account_deco.total_awards_remaining_pretty(project)
                }
                span { text ' Unpaid Revenue Shares' }
              }
            }
            tr {
              td(class: 'token-numbers') { text '×' }
              td {
                span(class: 'token-numbers revenue-per-share') { text project.revenue_per_share_pretty }
                span { text ' Current Share Value' }
              }
            }
            tr(class: 'money') {
              td(class: 'token-numbers') { text '=' }
              td {
                span(class: 'token-numbers total-revenue-unpaid') { text current_account_deco.total_revenue_unpaid_remaining_pretty(project) }
                span { text ' My Balance' }
              }
            }
          }
        }
      }
    end
  end
end
