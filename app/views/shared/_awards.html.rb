class Views::Shared::Awards < Views::Base
  needs :project, :awards, :show_recipient, :current_account

  def content
    div(class: 'table-scroll table-box') do
      table(class: 'award-rows') do
        tr(class: 'header-row') do
          th(class: 'small-1') { text 'Type' }
          th(class: 'small-1') { text 'Amount' }
          th(class: 'small-1') { text 'Quantity' }
          th(class: 'small-1') { text 'Total Amount' }
          th(class: 'small-1') { text 'Date' }
          th(class: 'small-2') { text 'Recipient' } if show_recipient
          th(class: 'small-2') { text 'Contribution' }
          th(class: 'small-2') { text 'Authorized By' }
          if project.ethereum_enabled
            th(class: 'small-2 blockchain-address') { text 'Blockchain Transaction' }
          end
        end
        awards.sort_by(&:created_at).reverse.each do |award|
          tr(class: 'award-row') do
            td(class: 'small-1 award-type') do
              text project.payment_description
            end

            td(class: 'small-1 award-unit-amount financial') do
              text award.unit_amount_pretty
            end

            td(class: 'small-1 award-quantity financial') do
              text award.quantity
            end

            td(class: 'small-1 award-total-amount financial') do
              text award.total_amount_pretty
            end
            td(class: 'small-2') do
              text raw award.created_at.strftime('%b %d, %Y').gsub(' ', '&nbsp;')
            end
            if show_recipient
              td(class: 'small-2 recipient') do
                img(src: award.authentication.slack_icon, class: 'icon avatar-img')
                text ' ' + award.recipient_display_name
              end
            end
            td(class: 'small-2 description') do
              strong award.award_type.name.to_s
              span(class: 'help-text') do
                text raw ": #{markdown_to_html award.description}" if award.description.present?
                br
                if award.proof_link
                  link_to award.proof_id, award.proof_link, target: '_blank'
                else
                  span award.proof_id
                end
              end
            end
            td(class: 'small-2') do
              if award.issuer_slack_icon
                img(src: award.issuer_slack_icon, class: 'icon avatar-img')
                text ' '
              end
              text award.issuer_display_name
            end
            if project.ethereum_enabled
              td(class: 'small-2 blockchain-address') do
                if award.ethereum_transaction_explorer_url
                  link_to award.ethereum_transaction_address_short, award.ethereum_transaction_explorer_url, target: '_blank'
                elsif award.recipient_address.blank? && current_account == award.recipient_account && show_recipient
                  link_to '(no account)', account_path
                elsif award.recipient_address.blank?
                  text '(no account)'
                else
                  text '(pending)'
                end
              end
            end
          end
        end
      end
    end
  end
end
