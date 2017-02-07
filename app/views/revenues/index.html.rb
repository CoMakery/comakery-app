class Views::Revenues::Index < Views::Projects::Base
  needs :project, :revenue

  def content
    render partial: 'shared/project_header'
    column {
      full_row {
        if project.owner_account == current_account
          column("large-6 medium-12 summary") {
            row {
              h3 "Summary"
            }

            row(class: 'total-revenue')  {
              span(class: "coin-numbers") { text project.total_revenue_pretty }
              text " Revenue"
            }

            row(class: 'revenue-shared') {
              span(class: "coin-numbers revenue-percentage") { text project.total_revenue_shared_pretty }
              text " Revenue Shared (#{project.royalty_percentage_pretty})"
            }
            row(class: 'total-awards')  {
              span(class: "coin-numbers") { text project.total_awarded }
              text ' Revenue Shares'
            }


            row(class: 'per-revenue-share')  {
              span(class: "coin-numbers") { text project.revenue_per_share_pretty }
              text ' Revenue Per Share'
            }
          }
          column("large-6 medium-12") {
            row {
              h3 "Record Revenue"
            }
            form_for [project, revenue] do |f|
              row {
                with_errors(project, :amount) {
                  label {
                    text "Amount"
                    div(class: 'input-group') {
                      span(class: "input-group-label denomination") { text project.currency_denomination }
                      f.text_field(:amount, class: 'input-group-field')
                    }
                  }
                }
              }

              row {
                with_errors(project, :comment) {
                  label {
                    text "Comment"
                    f.text_field(:comment)
                  }
                }
              }

              row {
                with_errors(project, :transaction_reference) {
                  label {
                    text "Transaction Reference"
                    f.text_field(:transaction_reference)
                  }
                }
              }

              row {
                f.submit("Record Revenue", class: buttonish(:expand))
              }
            end
          }
        end
      }
      br
      full_row {
        div(class: "table-scroll table-box revenues") {
          table(class: "table-scroll", style: "width: 100%") {
            tr(class: "header-row") {
              th { text "Date" }
              th { text "Amount" }
              th { text "Comment" }
              th { text "Transaction Reference" }
            }
            project.revenues.each do |revenue|
              tr(class: "award-row") {
                td(class: "date") {
                  div(class: "margin-small margin-collapse inline-block") { text revenue.created_at }
                }
                td(class: "amount") {
                  div(class: "margin-small margin-collapse inline-block") {
                    text "#{number_with_precision(revenue.amount, precision: 2, delimiter: ',')} #{revenue.currency}"
                  }
                }
                td(class: "comment") {
                  div(class: "margin-small margin-collapse inline-block") { text revenue.comment }
                }
                td(class: "transaction-reference") {
                  div(class: "margin-small margin-collapse inline-block") { text revenue.transaction_reference }
                }
              }
            end
          }
        }
      }
    }
  end
end