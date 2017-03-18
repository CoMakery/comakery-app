class Views::Authentications::Show < Views::Base
  needs :current_account, :authentication, :awards

  def content
    h4 'Bank Account to Receive Payments'
    div {
      row {
        column("large-6 small-12") {
          label {
            text "Routing Number"
            text_field_tag 'routing_number'
          }
        }
        column("large-6 small-12") {
          label {
            text "Bank Account Number"
            text_field_tag 'account_number'
          }
        }
      }
      row {
        column("large-6 small-12") {
          label {
            text "Account Holder Name"
            text_field_tag 'account_holder_name'
          }
        }
        column("large-6 small-12") {
          label {
            text "Account Holder Type"
            options = capture do
              options_for_select([
                  ["Individual", "individual"],
                  ["Company", "company"]
              ])
            end
            select_tag 'account_holder_type', options
          }
        }
      }
      row {
        column("large-6 small-12") {
          label {
            text "Country"
            options = capture do
              options_for_select(['US'])
            end
            select_tag 'country', options
          }
        }
        column("large-6 small-12") {
          label {
            text "Currency"
            options = capture do
              options_for_select(['USD'])
            end
            select_tag 'currency', options
          }
        }
      }
      row {
        column("large-6 small-12") {
          button_tag "Submit", class: buttonish(:expand), id: 'stripe_bank_account_submit'
        }
      }
    }
    br
    br

    h4 'Ethereum'

    p {
      text "You can download an Ethereum wallet from "
      link_to("Ethereum.org", "http://www.ethereum.org", target: "_blank")
      text " to create an account. Enter your Ethereum account address below. "
      text "Then you will receive your CoMakery awards in your Ethereum account!"
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

    awards.group_by { |award| award.project.id }.each do |(_, awards_for_project)|
      project = awards_for_project.first.project.decorate
      h3 {
        link_to project.title, project_awards_path(project)
      }
      render partial: "shared/awards", locals: {
        awards: AwardDecorator.decorate_collection(awards_for_project),
        show_recipient: false,
        project: project
      }
    end
  end
end
