class Views::Authentications::Show < Views::Base
  needs :authentication, :awards

  def content
    div(class: "ethereum_address") {
      div(class: "hide edit-ethereum-address") {
        row {
          form_for authentication.account do |f|
            with_errors(authentication.account, :ethereum_address) {
              column("small-2") {
                label(for: :"account_ethereum_address") {
                  text "Ethereum Address "
                }
              }
              column("small-6") {
                f.text_field :ethereum_address
              }
              column("small-4") {
                f.submit "Save"
                a(href: "#", "data-toggles": ".edit-ethereum-address,.view-ethereum-address") { text "Cancel" }
              }
            }
          end
        }
      }
      div(class: "view-ethereum-address") {
        row {
          column("small-2") {
            text "Ethereum Address"
          }
          column("small-10") {
            text authentication.account.ethereum_address
            a(href: "#", "data-toggles": ".edit-ethereum-address,.view-ethereum-address") { text "Edit" }
          }
        }
      }
    }

    hr

    awards.group_by { |award| award.award_type.project_id }.each do |(_, awards_for_project)|
      h3 "#{awards_for_project.first.award_type.project.title} awards"
      render partial: "shared/awards", locals: {awards: awards_for_project, show_recipient: false}
    end
  end
end