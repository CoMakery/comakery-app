class Views::Shared::Table::UnpaidRevenueShares < Views::Projects::Base
  needs :project

  def content
    if project.revenue_share?
      column('large-4 medium-12 summary float-left unpaid-revenue-shares') do
        row(class: 'money') { h3 project.payment_description.to_s }

        row(class: 'total-revenue table-box') do
          table do
            tr do
              td(class: 'token-numbers') {}
              td do
                span(class: 'token-numbers total-awarded') { text "#{project.total_awarded_pretty} " }
                span { text 'Lifetime Revenue Shares Awarded' }
              end
            end
            tr do
              td(class: 'token-numbers') { text '-' }
              td do
                span(class: 'token-numbers awards-redeemed') { text "#{project.total_awards_redeemed_pretty} " }
                span { text 'Revenue Shares Paid' }
              end
            end
            tr(class: 'money') do
              td(class: 'token-numbers') { text '=' }
              td do
                span(class: 'token-numbers awards-outstanding') { text "#{project.total_awards_outstanding_pretty} " }
                span { text 'Unpaid Revenue Shares' }
              end
            end
          end
        end
      end
    end
  end
end
