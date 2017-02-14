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
              div(class: 'table-box') {
                table(class: "table-scroll summary-table") {
                  tr(class: 'total-revenue') {
                    td { text " Revenue" }
                    td(class: "coin-numbers") { text project.total_revenue_pretty }
                  }

                  tr(class: 'revenue-shared') {
                    td { text " Revenue Shared (#{project.royalty_percentage_pretty}) " }
                    td(class: "coin-numbers revenue-percentage") { text project.total_revenue_shared_pretty }
                  }
                  tr(class: 'total-awards') {
                    td { text ' Revenue Shares' }
                    td(class: "coin-numbers") { text project.total_awarded_pretty }
                  }

                  tr(class: 'revenue-per-share') {
                    td { text ' Revenue Per Share' }
                    td(class: "coin-numbers") { text project.revenue_per_share_pretty }
                  }
                }
              }
            }
          }
          column("large-6 medium-12") {
            row {
              h3 "Record Revenue"
            }
            form_for [project, revenue] do |f|
              row {
                with_errors(revenue, :amount) {
                  label {
                    span(class: 'required') {
                      text "Amount"
                    }
                    div(class: 'input-group financial') {
                      span(class: "input-group-label denomination") { text project.currency_denomination }
                      f.text_field(:amount, class: 'input-group-field')
                    }
                  }
                }
              }

              row {
                with_errors(revenue, :comment) {
                  label {
                    text "Comment"
                    f.text_field(:comment)
                  }
                }
              }

              row {
                with_errors(revenue, :transaction_reference) {
                  label {
                    text "Transaction Reference"
                    f.text_field(:transaction_reference, class: 'financial')
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
              th { text "Recorded By" }
            }
            project.revenue_history.each do |revenue|
              tr(class: "award-row") {
                td(class: "date financial") {
                  div(class: "margin-small margin-collapse inline-block") { text revenue.created_at }
                }
                td(class: "amount financial") {
                  div(class: "margin-small margin-collapse inline-block") {
                    text revenue.amount_pretty
                  }
                }
                td(class: "comment") {
                  div(class: "margin-small margin-collapse inline-block") { text revenue.comment }
                }
                td(class: "transaction-reference financial") {
                  div(class: "margin-small margin-collapse inline-block") { text revenue.transaction_reference }
                }
                td(class: "recorded-by small-2") {
                  if revenue.issuer_slack_icon
                    img(src: revenue.issuer_slack_icon, class: "icon avatar-img")
                    text " "
                  end

                  div(class: "margin-small margin-collapse inline-block") { text revenue.issuer_display_name }
                }
              }
            end
          }
        }
      }
    }
  end
end