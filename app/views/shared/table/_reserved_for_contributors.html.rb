class Views::Shared::Table::ReservedForContributors < Views::Projects::Base
  needs :project

  def content
    if project.revenue_share?
      column("large-4 medium-12 summary float-left") {
        row(class: 'money') { h3 "Reserved for Contributors" }
        row(class: 'total-revenue table-box') {
          table {
            tr {
              td(class: "coin-numbers") {}
              td {
                span(class: "coin-numbers") { text "#{project.total_revenue_pretty} " }
                span { text "Total Project Revenue" }
              }
            }
            tr {
              td(class: "coin-numbers") { text "×" }
              td {
                span(class: "coin-numbers") { text "#{project.royalty_percentage_pretty} " }
                span { text "Reserved for Contributors" }
              }
            }
            tr(class: 'money') {
              td(class: "coin-numbers") { text "=" }
              td {
                span(class: "coin-numbers revenue-percentage") { text "#{project.total_revenue_shared_pretty} " }
                span { text "Reserved for Contributors" }
              }
            }
          }
        }
      }
    end
  end
end