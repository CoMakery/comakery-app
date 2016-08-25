class Views::Authentications::Show < Views::Base
  needs :current_account, :authentication, :awards

  def content
    p {
      text "You can download an Ethereum wallet from "
      link_to("Ethereum.org", "http://www.ethereum.org", target: "_blank")
      text " to create an account. Enter your Ethereum account address below. "
      text "Then you will receive your CoMakery project coin awards in your Ethereum account!"
    }
    p {
      link_to("Get a wallet now", "http://www.ethereum.org", target: "_blank", class: buttonish)
    }
    div(class: "ethereum_wallet") {
      div(class: "hide edit-ethereum-wallet") {
        row {
          form_for authentication.account, url: "/account" do |f|
            with_errors(current_account, :ethereum_wallet) {
              column("small-3") {
                label(for: :"account_ethereum_wallet") {
                  text "Ethereum Address ("
                  a(href: "#", "data-toggles": ".edit-ethereum-wallet,.view-ethereum-wallet") { text "Cancel" }
                  text ")"
                }
              }
              column("small-6") {
                f.text_field :ethereum_wallet
              }
              column("small-3") {
                f.submit "Save"
              }
            }
          end
        }
      }
      div(class: "view-ethereum-wallet") {
        row {
          column("small-3") {
            text "Ethereum Address ("
            a(href: "#", "data-toggles": ".edit-ethereum-wallet,.view-ethereum-wallet") { text "Edit" }
            text ")"
          }
          column("small-9") {
            # link_to authentication.account.ethereum_wallet, "https://www.etherchain.org/account/#{authentication.account.ethereum_wallet}", target: "_blank"
            text authentication.account.ethereum_wallet
          }
        }
      }
    }

    hr

    awards.group_by { |award| award.award_type.project_id }.each do |(_, awards_for_project)|
      h3 "#{awards_for_project.first.award_type.project.title} awards", class: "awards-title"
      render partial: "shared/awards", locals: {awards: AwardDecorator.decorate_collection(awards_for_project), show_recipient: false}
    end
  end
end
