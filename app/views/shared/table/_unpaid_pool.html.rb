class Views::Shared::Table::UnpaidPool < Views::Projects::Base
  needs :project

  def content
    if project.revenue_share?
      column('large-4 medium-12 summary float-left unpaid-pool') do
        row(class: 'money') { h3 'Contributor Pool Balance' }
        row(class: 'total-revenue table-box') do
          table do
            tr do
              td(class: 'token-numbers') {}
              td do
                span(class: 'token-numbers total-revenue-shared') { text "#{project.total_revenue_shared_pretty} " }
                span { text 'Reserved for Contributors' }
              end
            end
            tr do
              td(class: 'token-numbers') { text '-' }
              td do
                span(class: 'token-numbers total-paid-to-contributors') { text "#{project.total_paid_to_contributors_pretty} " }
                span { text 'Total Payments To Contributors' }
              end
            end
            tr(class: 'money') do
              td(class: 'token-numbers') { text '=' }
              td do
                span(class: 'token-numbers revenue-shared-unpaid') { text "#{project.total_revenue_shared_unpaid_pretty} " }
                span { text 'Contributor Pool Balance' }
              end
            end
          end
        end
      end
    end
  end
end
