class Views::Shared::Table::UnpaidPool < Views::Projects::Base
  needs :project

  def content
    if project.revenue_share?
      column("large-4 medium-12 summary float-left") {
        row(class: 'money') { h3 "Unpaid Pool" }
        row(class: 'total-revenue table-box') {
          table {
            tr {
              td(class: "coin-numbers") {}
              td {
                span(class: "coin-numbers revenue-percentage") { text "#{project.total_revenue_shared_pretty} " }
                span { text "Reserved for Contributors" }
              }
            }
            tr {
              td(class: "coin-numbers") { text "-" }
              td {
                span(class: "coin-numbers revenue-percentage") { text "#{project.total_paid_to_contributors_pretty} " }
                span { text "Total Payments To Contributors" }
              }
            }
            tr(class: 'money') {
              td(class: "coin-numbers") { text "=" }
              td {
                span(class: "coin-numbers revenue-percentage") { text "#{project.total_revenue_shared_unpaid_pretty} " }
                span { text "Unpaid Pool" }
              }
            }
          }
        }
      }
    end
  end
end