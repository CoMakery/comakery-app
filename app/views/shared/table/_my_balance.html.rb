class Views::Shared::Table::MyBalance < Views::Projects::Base
  needs :project, :current_auth

  def content
    if project.revenue_share?
      column("large-4 medium-12 summary float-left") {
        row(class: 'money') {
          h3 "My Balance"
        }
        row(class: 'total-revenue table-box') {
          table {
            tr {
              td(class: "coin-numbers") { text "" }
              td {
                span(class: "coin-numbers revenue-percentage") {
                  text current_auth.total_awards_remaining_pretty(project)
                }
                span { text " Unpaid Revenue Shares" }
              }
            }
            tr {
              td(class: "coin-numbers") { text "×" }
              td {
                span(class: "coin-numbers revenue-percentage") { text project.revenue_per_share_pretty }
                span { text ' Current Share Value' }
              }
            }
            tr(class: 'money') {
              td(class: "coin-numbers") { text "=" }
              td {
                span(class: "coin-numbers revenue-percentage") { text current_auth.total_revenue_unpaid_remaining_pretty(project) }
                span { text ' My Balance' }
              }
            }
          }
        }
      }
    end
  end
end