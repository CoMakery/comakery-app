class Views::Revenues::Index < Views::Projects::Base
  needs :project, :revenue

  def content
    render partial: 'shared/project_header'

    column {
      if project.account == current_account
        full_row { h3 'Record Project Revenue' }
        form_for [project, revenue] { |f|
          div(class: 'content-box summary menu simple') {
            row {
              column('large-4 float-left') {
                with_errors(revenue, :amount) {
                  label {
                    text 'Amount'
                    span(class: 'input-group financial') {
                      span(class: 'input-group-label denomination') { text project.currency_denomination }
                      f.text_field(:amount)
                    }
                  }
                }
              }

              column('large-4 float-left') {
                with_errors(revenue, :comment) {
                  label {
                    text 'Comment'
                    f.text_field(:comment)
                  }
                }
              }

              column('large-4 float-left') {
                with_errors(revenue, :transaction_reference) {
                  label {
                    text 'Transaction Reference'
                    f.text_field(:transaction_reference, class: 'financial')
                  }
                }
              }
            }
            full_row {
              f.submit('Record Revenue', class: buttonish(:expand))
            }
          }
        }
      end

      full_row {
        render partial: 'shared/table/reserved_for_contributors'
        render partial: 'shared/table/unpaid_pool'
      }

      full_row {
        if project.revenue_history.any?
          h3 'Project Revenue'
          div(class: 'table-scroll table-box revenues') {
            table(class: 'table-scroll', style: 'width: 100%') {
              tr(class: 'header-row') {
                th { text 'Date' }
                th { text 'Amount' }
                th { text 'Comment' }
                th { text 'Transaction Reference' }
                th { text 'Recorded By' }
              }
              project.revenue_history.each do |revenue|
                tr(class: 'award-row') {
                  td(class: 'date financial') {
                    div(class: 'margin-small margin-collapse inline-block') { text revenue.created_at }
                  }
                  td(class: 'amount financial') {
                    div(class: 'margin-small margin-collapse inline-block') {
                      text revenue.amount_pretty
                    }
                  }
                  td(class: 'comment') {
                    div(class: 'margin-small margin-collapse inline-block') { text revenue.comment }
                  }
                  td(class: 'transaction-reference financial') {
                    div(class: 'margin-small margin-collapse inline-block') { text revenue.transaction_reference }
                  }
                  td(class: 'recorded-by small-2') {
                    img(src: account_image_url(revenue.recorded_by, 34), class: 'icon avatar-img')
                      text ' '

                    div(class: 'margin-small margin-collapse inline-block') { text revenue.issuer_display_name }
                  }
                }
              end
            }
          }
        else
          div(class: 'revenues') { text 'No revenue yet.' }
        end
      }
    }
  end
end
