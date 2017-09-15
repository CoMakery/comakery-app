class Views::Shared::Table::ReservedForContributors < Views::Projects::Base
  needs :project

  def content
    if project.revenue_share?
      column('large-4 medium-12 summary float-left reserved-for-contributors') {
        row(class: 'money') { h3 'Reserved for Contributors' }
        row(class: 'table-box') {
          table {
            tr(class: 'token-numbers') {
              td {}
              td {
                span(class: 'total-revenue') { text "#{project.total_revenue_pretty} " }
                span { text 'Total Project Revenue' }
              }
            }
            tr(class: 'token-numbers') {
              td { text '×' }
              td {
                span(class: 'royalty-percentage') { text "#{project.royalty_percentage_pretty} " }
                span { text 'Reserved for Contributors' }
              }
            }
            tr(class: 'money token-numbers') {
              td { text '=' }
              td {
                span(class: 'total-revenue-shared') { text "#{project.total_revenue_shared_pretty} " }
                span { text 'Reserved for Contributors' }
              }
            }
          }
        }
      }
    end
  end
end
