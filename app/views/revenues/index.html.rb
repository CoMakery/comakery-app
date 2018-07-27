class Views::Revenues::Index < Views::Projects::Base
  needs :project, :revenue

  def content
    render partial: 'shared/project_header'

    column do
      if project.account == current_account
        full_row { h3 'Record Project Revenue' }
        form_for [project, revenue] do |f|
          div(class: 'content-box summary menu simple') do
            row do
              column('large-4 float-left') do
                with_errors(revenue, :amount) do
                  label do
                    text 'Amount'
                    span(class: 'input-group financial') do
                      span(class: 'input-group-label denomination') { text project.currency_denomination }
                      f.text_field(:amount)
                    end
                  end
                end
              end

              column('large-4 float-left') do
                with_errors(revenue, :comment) do
                  label do
                    text 'Comment'
                    f.text_field(:comment)
                  end
                end
              end

              column('large-4 float-left') do
                with_errors(revenue, :transaction_reference) do
                  label do
                    text 'Transaction Reference'
                    f.text_field(:transaction_reference, class: 'financial')
                  end
                end
              end
            end
            full_row do
              f.submit('Record Revenue', class: buttonish(:expand))
            end
          end
        end
      end

      full_row do
        render partial: 'shared/table/reserved_for_contributors'
        render partial: 'shared/table/unpaid_pool'
      end

      full_row do
        if project.revenue_history.any?
          h3 'Project Revenue'
          div(class: 'table-scroll table-box revenues') do
            table(class: 'table-scroll', style: 'width: 100%') do
              tr(class: 'header-row') do
                th { text 'Date' }
                th { text 'Amount' }
                th { text 'Comment' }
                th { text 'Transaction Reference' }
                th { text 'Recorded By' }
              end
              project.revenue_history.each do |revenue|
                tr(class: 'award-row') do
                  td(class: 'date financial') do
                    div(class: 'margin-small margin-collapse inline-block') { text revenue.created_at }
                  end
                  td(class: 'amount financial') do
                    div(class: 'margin-small margin-collapse inline-block') do
                      text revenue.amount_pretty
                    end
                  end
                  td(class: 'comment') do
                    div(class: 'margin-small margin-collapse inline-block') { text revenue.comment }
                  end
                  td(class: 'transaction-reference financial') do
                    div(class: 'margin-small margin-collapse inline-block') { text revenue.transaction_reference }
                  end
                  td(class: 'recorded-by small-2') do
                    img(src: account_image_url(revenue.recorded_by, 34), class: 'icon avatar-img')
                      text ' '

                    div(class: 'margin-small margin-collapse inline-block') { text revenue.issuer_display_name }
                  end
                end
              end
            end
          end
        else
          div(class: 'revenues') { text 'No revenue yet.' }
        end
      end
    end
  end
end
