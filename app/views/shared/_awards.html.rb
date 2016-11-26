class Views::Shared::Awards < Views::Base
  needs :project, :awards, :show_recipient, :current_account

  def content
    div(class: "table-scroll") {
      table(class: "award-rows") {
        tr(class: "header-row") {
          th(class: "small-1") { text "#{project.payment_description} Earned" }
          th(class: "small-2") { text "Date" }
          if show_recipient
            th(class: "small-2") { text "Recipient" }
          end
          th(class: "small-3") { text "Contribution" }
          th(class: "small-2") { text "Authorized By" }
          if project.ethereum_enabled
            th(class: "small-2 blockchain-address") { text "Blockchain Transaction" }
          end

          awards.sort_by(&:created_at).reverse.each do |award|
            tr(class: "award-row") {
              td(class: "small-1") {
                text project.currency_denomination
                text number_with_delimiter(award.award_type.amount, :delimiter => ',')
              }
              td(class: "small-2") {
                text raw award.created_at.strftime("%b %d, %Y").gsub(' ', '&nbsp;')
              }
              if show_recipient
                td(class: "small-2") {
                  img(src: award.authentication.slack_icon, class: "icon avatar-img")
                  text " " + award.recipient_display_name
                }
              end
              td(class: "small-3 description") {
                if award.proof_link
                  link_to award.proof_id_short, award.proof_link, target: '_blank'
                else
                  span award.proof_id_short
                end
                br
                strong "#{award.award_type.name}"
                text raw ": #{markdown_to_html award.description}" if award.description.present?
              }
              td(class: "small-2") {
                if award.issuer_slack_icon
                  img(src: award.issuer_slack_icon, class: "icon avatar-img")
                  text " "
                end
                text award.issuer_display_name
              }
              if project.ethereum_enabled
                td(class: "small-2 blockchain-address") {
                  if award.ethereum_transaction_explorer_url
                    link_to award.ethereum_transaction_address_short, award.ethereum_transaction_explorer_url, target: '_blank'
                  elsif award.recipient_address.blank? && current_account == award.recipient_account && show_recipient
                    link_to '(no account)', account_path
                  elsif award.recipient_address.blank?
                    text '(no account)'
                  else
                    text '(pending)'
                  end
                }
              end
            }
          end
        }
      }
    }
  end
end
