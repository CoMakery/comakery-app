class Views::Shared::Table::UnpaidRevenueShares < Views::Projects::Base
  needs :project

  def content
    if project.revenue_share?
      column("large-4 medium-12 summary float-left") {
        row(class: 'money') { h3 "Unpaid #{project.payment_description}" }

        row(class: 'total-revenue table-box') {
          table {
            tr {
              td(class: "coin-numbers") {}
              td {
                span(class: "coin-numbers revenue-percentage") { text "#{project.total_awarded_pretty} " }
                span { text "Lifetime Revenue Shares Awarded" }
              }
            }
            tr {
              td(class: "coin-numbers") { text "-" }
              td {
                span(class: "coin-numbers revenue-percentage") { text "#{project.total_awards_redeemed_pretty} " }
                span { text "Revenue Shares Paid" }
              }
            }
            tr(class: 'money') {
              td(class: "coin-numbers") { text "=" }
              td {
                span(class: "coin-numbers revenue-percentage") { text "#{project.total_awards_outstanding_pretty} " }
                span { text "Unpaid Revenue Shares" }
              }
            }
          }
        }
      }
    end
  end
end