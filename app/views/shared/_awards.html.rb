class Views::Shared::Awards < Views::Base
  needs :awards, :show_recipient

  def content
    div(class: "award-rows") {
      row(class: "header-row") {
        column("small-2") { div(class: "header") { text "Submitted" } }
        column("small-2") { div(class: "header") { text "Award" } }
        column("small-2") { div(class: "header") { text "Recipient" } } if show_recipient
        column("small-4") { div(class: "header") { text "Contribution" } }
        column("small-2") { div(class: "header") { text "Sender" } }
        column("small-2") { div(class: "header") {} } unless show_recipient
      }
      awards.sort_by(&:created_at).reverse.each do |award|
        row(class: "award-row") {
          column("small-2") {
            text award.created_at.strftime("%b %d, %Y")
          }
          column("small-2") {
            text number_with_delimiter(award.award_type.amount, :delimiter => ',')
          }
          if show_recipient
            column("small-2") {
              text award.recipient_display_name
            }
          end
          column("small-4") {
            div award.award_type.name
            div(class: "text-gray") { text award.description }
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
