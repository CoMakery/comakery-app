class Views::Shared::Table::ReservedForContributors < Views::Projects::Base
  needs :project

  def content
    if project.revenue_share?
      column('large-4 medium-12 summary float-left reserved-for-contributors') do
        row(class: 'money') { h3 'Reserved for Contributors' }
        row(class: 'table-box') do
          table do
            tr(class: 'token-numbers') do
              td {}
              td do
                span(class: 'total-revenue') { text "#{project.total_revenue_pretty} " }
                span { text 'Total Project Revenue' }
              end
            end
            tr(class: 'token-numbers') do
              td { text '×' }
              td do
                span(class: 'royalty-percentage') { text "#{project.royalty_percentage_pretty} " }
                span { text 'Reserved for Contributors' }
              end
            end
            tr(class: 'money token-numbers') do
              td { text '=' }
              td do
                span(class: 'total-revenue-shared') { text "#{project.total_revenue_shared_pretty} " }
                span { text 'Reserved for Contributors' }
              end
            end
          end
        end
      end
    end
  end
end
