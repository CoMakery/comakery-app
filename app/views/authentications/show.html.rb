class Views::Authentications::Show < Views::Base
  needs :current_account, :authentication, :awards

  def content
    p {
      text "CoMakery distributes project coins to your private wallet using the Ethereum blockchain. You can download your Ethereum wallet from "
      link_to("Ethereum.org", "http://www.ethereum.org")
      text ". Open your wallet enter your Ethereum address to receive your CoMakery project coins! "
      text "Once you have entered your Ethereum address you will be able to see your project coins in blockchain explorers like Etherchain.com and in your Ethereum wallet."
    }
    p {
      button_to("Get a wallet now", "http://www.ethereum.org")
    }
    div(class: "ethereum_address") {
      div(class: "hide edit-ethereum-address") {
        row {
          form_for authentication.account do |f|
            with_errors(current_account, :ethereum_address) {
              column("small-3") {
                label(for: :"account_ethereum_address") {
                  text "Ethereum Address ("
                  a(href: "#", "data-toggles": ".edit-ethereum-address,.view-ethereum-address") { text "Cancel" }
                  text ")"
                }
              }
              column("small-6") {
                f.text_field :ethereum_address
              }
              column("small-3") {
                f.submit "Save"
              }
            }
          end
        }
      }
      div(class: "view-ethereum-address") {
        row {
          column("small-3") {
            text "Ethereum Address ("
            a(href: "#", "data-toggles": ".edit-ethereum-address,.view-ethereum-address") { text "Edit" }
            text ")"
          }
          column("small-9") {
            link_to authentication.account.ethereum_address, "https://www.etherchain.org/account/#{authentication.account.ethereum_address}"
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