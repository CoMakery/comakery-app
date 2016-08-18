class Views::Shared::Awards < Views::Base
  needs :awards, :show_recipient

  def content
    div(class: "award-rows") {
      row(class: "header-row") {
        column("small-1") { div(class: "header") { text "Submitted" } }
        column("small-1") { div(class: "header") { text "Award" } }
        column("small-2") { div(class: "header") { text "Blockchain Transaction" } }
        column("small-2") { div(class: "header") { text "Recipient" } } if show_recipient
        column("small-2") { div(class: "header") { text "Award Type" } }
        column("small-2") { div(class: "header") { text "Description" } }
        column("small-2") { div(class: "header") { text "Sender" } }
        column("small-2") { div(class: "header") {} } unless show_recipient
      }
      awards.sort_by(&:created_at).reverse.each do |award|
        row(class: "award-row") {
          column("small-1") {
            text raw award.created_at.strftime("%b %d, %Y").gsub(' ', '&nbsp;')
          }
          column("small-1") {
            text number_with_delimiter(award.award_type.amount, :delimiter => ',')
          }
          column("small-2") {
            if award.ethereum_transaction_address
              link_to "#{award.ethereum_transaction_address[0...10]}...",
                "https://#{ENV['ETHERCAMP_SUBDOMAIN']}.ether.camp/transaction/#{award.ethereum_transaction_address}",
                target: '_blank'
            else
              text '(pending)'
            end
          }
          if show_recipient
            column("small-2") {
              text award.recipient_display_name
            }
          end
          column("small-2") {
            div award.award_type.name
          }
          column("small-2") {
            div(class: "text-gray") { text raw markdown_to_html award.description }
          }
          column("small-2") {
            text award.issuer_display_name
          }
          column("small-2") {} unless show_recipient
        }
      end
    }
  end
end
