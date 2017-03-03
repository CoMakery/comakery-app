class Views::Payments::Index < Views::Projects::Base
  needs :project, :payment, :current_auth

  def content
    render partial: 'shared/project_header'
    column {
      if current_auth.present?
      full_row {

          column("large-6 medium-12 summary") {
            row {
              h3 "My Summary"
              div(class: 'table-box') {
                table(class: "table-scroll summary-table") {
                  tr(class: '') {
                    td { text "My Revenue Shares" }
                    td(class: "coin-numbers my-revenue-shares") {
                      span {
                        text current_auth.total_awards_remaining_pretty(project)
                      }
                      span { text " of #{project.total_awards_outstanding_pretty} total" }
                    }
                  }

                  tr(class: '') {
                    td { text "My Balance" }
                    td(class: "coin-numbers my-balance") {
                      span {
                        text current_auth.total_revenue_unpaid_remaining_pretty(project)
                      }
                      span { text " of #{project.total_revenue_shared_unpaid_rounded} total" }
                    }
                  }
                }
              }
            }
          }
          column("large-6 medium-12 content-box") {
            form_for [project, payment], html: {class: 'conversational-form'} do |f|
              row {
                with_errors(payment, :quantity_redeemed) {
                  text "Redeem "
                  f.number_field(:quantity_redeemed, class: 'input-group-field')
                  text " revenue shares"
                }
              }

              row {
                p {
                  text "At "
                  span(class: 'revenue-per-share') { text project.revenue_per_share_pretty }
                  text " each"
                }
              }

              row {
                f.submit("Redeem My Revenue Shares", class: buttonish(:expand))
              }
            end
          }
        }
      end
      br
      full_row {
        if project.payment_history.any?
          div(class: "table-scroll table-box payments") {


            table(class: "table-scroll", style: "width: 100%") {
              tr(class: "header-row") {
                th { text "Date" }
                th { text "Payee" }
                th { text "Share Value" }
                th { text "Quantity" }
                th { text "Total Value" }
                th { text "Transaction Fee" }

                th { text "Transaction Reference" }
                th { text "Total Payment" }
                th { text "Issuer" }
                th { text "Status" }
              }

              project.payment_history.decorate.each do |payment|
                tr(class: "award-row") {
                  payment_td('created-at') { text payment.created_at }

                  payment_td('payee') {
                    if payment.payee_avatar
                      img(src: payment.payee_avatar, class: "icon avatar-img")
                      text " "
                    end

                    text payment.payee_name
                  }
                  payment_td('share-value') { text payment.share_value_pretty }
                  payment_td('quantity-redeemed') { text payment.quantity_redeemed }

                  payment_td('total-value') { text payment.total_value_pretty }

                  if !payment.reconciled? && policy(project).edit?
                    form_for([project, payment]) do |f|
                      payment_td('transaction-fee') { f.text_field :transaction_fee, value: payment.transaction_fee }

                      payment_td('transaction-reference') do
                        f.text_field :transaction_reference, value: payment.transaction_reference
                      end

                      payment_td('total-payment') { f.submit "Reconcile", class: 'button' }
                    end
                  else
                    payment_td('transaction-fee') { text payment.transaction_fee_pretty }
                    payment_td('transaction-reference') { text payment.transaction_reference }
                    payment_td('total-payment') { text payment.total_payment_pretty }
                  end

                  payment_td('issuer') {
                    if payment.issuer_avatar
                      img(src: payment.issuer_avatar, class: "icon avatar-img")
                      text " "
                    end

                    text payment.issuer_name
                  }
                  payment_td('status') { text payment.status }

                }
              end
            }
          }
        else
          div(class: 'payments') { text "No payments yet." }
        end
      }
    }
  end

  def payment_td(column_matcher)
    td {
      span(class: "margin-small margin-collapse inline-block #{column_matcher}") { yield }
    }
  end

  def conversational
    span(class: 'conversational-form') { yield }
  end
end