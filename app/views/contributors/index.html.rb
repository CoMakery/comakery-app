class Views::Contributors::Index < Views::Projects::Base
  needs :project, :award_data

  def content
    render partial: 'shared/project_header'
    column do
      full_row do
        if award_data[:contributions].present?
          column('large-4 medium-12 summary float-left') do
            h3 "Lifetime #{project.payment_description} Awarded To Contributors"

              p do
                div(id: 'award-percentages', class: 'royalty-pie') {}
              end
              content_for :js do
                make_charts
              end
          end
        end

        render partial: 'shared/table/unpaid_revenue_shares'
        render partial: 'shared/table/unpaid_pool'
      end

      full_row do
        if award_data[:contributions_summary].present?
          div(class: 'table-scroll table-box contributors') do
            table(class: 'table-scroll', style: 'width: 100%') do
              tr(class: 'header-row') do
                th 'Contributors'
                th { text "Lifetime #{project.payment_description} Awarded" }
                th { text "Unpaid #{project.payment_description}" }
                th { text 'Unpaid Revenue Share Balance' } if project.revenue_share?
                th { text 'Lifetime Paid' } if project.revenue_share?
              end
              project.contributors_by_award_amount.each do |contributor_auth|
                tr(class: 'award-row') do
                  td(class: 'contributor') do
                    img(src: contributor_auth.slack_icon, class: 'icon avatar-img')
                    div(class: 'margin-small margin-collapse inline-block') { text contributor_auth.display_name }
                  end
                  td(class: 'awards-earned financial') do
                    span(class: 'margin-small') do
                      text contributor_auth.total_awards_earned_pretty(project)
                    end
                  end
                  td(class: 'award-holdings financial') do
                    span(class: 'margin-small') do
                      text text contributor_auth.total_awards_remaining_pretty(project)
                    end
                  end

                  if project.revenue_share?
                    td(class: 'holdings-value financial') do
                      span(class: 'margin-small') do
                        text contributor_auth.total_revenue_unpaid_remaining_pretty(project)
                      end
                    end
                  end
                  if project.revenue_share?
                    td(class: 'paid hidden financial') do
                      span(class: 'margin-small') do
                        text contributor_auth.total_revenue_paid_pretty(project)
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def make_charts
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        window.pieChart("#award-percentages", {"content": #{pie_chart_data}});
      });
    JAVASCRIPT
  end

  def pie_chart_data
    award_data[:contributions_summary_pie_chart].map do |award|
      { label: award[:name], value: award[:net_amount] }
    end.to_json
  end
end
