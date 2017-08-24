class Views::Shared::Table::CurrentShareValue < Views::Projects::Base
  needs :project

  def content
    if project.revenue_share?
      column('large-4 medium-12 summary float-left current-share-value') {
        row(class: 'money') {
          h3 'Current Share Value'
        }
        row(class: 'total-revenue table-box') {
          table {
            tr {
              td(class: 'token-numbers') { text '' }
              td {
                span(class: 'token-numbers total-revenue-unpaid') { text "#{project.total_revenue_shared_unpaid_pretty} " }
                span { text 'Contributor Pool Balance' }
              }
            }
            tr {
              td(class: 'token-numbers') { text '÷' }
              td {
                span(class: 'token-numbers unpaid-revenue-shares') { text "#{project.total_awards_outstanding_pretty} " }
                span { text 'Unpaid Revenue Shares' }
              }
            }
            tr(class: 'money') {
              td(class: 'token-numbers') { text '=' }
              td {
                span(class: 'token-numbers revenue-per-share') { text project.revenue_per_share_pretty }
                span { text ' Current Share Value' }
              }
            }
          }
        }
      }
    end
  end
end
