module Views
  module Projects
    class Form < Views::Base
      needs :project, :slack_channels

      def content
        form_for project do |f|
          row {
            column("large-6 small-12") {
              div(class: 'content-box') {
                h3 "Project Settings"

                with_errors(project, :title) {
                  label {
                    text "Title"
                    f.text_field :title
                  }
                }
                with_errors(project, :payment_type) {
                  label {
                    text "Award Payment Type"
                    question_tooltip "Project collaborators to your project will receive royalties denominated in a specific currency or direct payments in project coins for their work contributions."
                    f.select(:payment_type,
                             [["Royalties paid in US Dollars ($)", "royalty_usd"],
                              ["Royalties paid in Bitcoin (฿)", "royalty_btc"],
                              # ["Royalties paid in Ether (Ξ)", "royalty_eth"],
                              ["Project Coin direct payment", "project_coin"]],
                              {selected: project.payment_type,include_blank: false}
                    )
                    ethereum_beta(f)
                  }
                }
                with_errors(project, :maximum_coins) {
                  label {
                    text "Maximum Awards Outstanding"
                    question_tooltip "Select it carefully,
                      it cannot be changed after it has been set.
                      For royalties this is the maximum amount of unpaid royalties.
                      For project coins this is the maximum number of project coins that can be issued.
                      When royalties are paid or project coins are burned they are not included in this total.
                      Select a high enough number
                      so you have room for the future."
                    f.text_field :maximum_coins, type: "number", disabled: !project.new_record?
                  }
                }
                with_errors(project, :slack_channel) {
                  label {
                    i(class: "fa fa-slack")
                    text " Slack Channel "
                    question_tooltip "Select where project notifications will be sent."
                    options = capture do
                      options_for_select([[nil, nil]].concat(slack_channels), selected: project.slack_channel)
                    end
                    select_tag "project[slack_channel]", options, html: {id: "project_slack_channel"}
                  }
                }
                with_errors(project, :description) {
                  label {
                    text "Description"
                    f.text_area :description
                    link_to("Styling with Markdown is Supported", "https://guides.github.com/features/mastering-markdown/", class: "help-text")
                  }
                }
                with_errors(project, :tracker) {
                  label {
                    i(class: "fa fa-tasks")
                    text " Project Tracker"
                    f.text_field :tracker, placeholder: "https://trello.com/my-project"
                  }
                }
                with_errors(project, :video_url) {
                  label {
                    i(class: "fa fa-youtube")
                    text " Video "
                    question_tooltip "A video url representing your project. Must be a Youtube url."
                    f.text_field :video_url, placeholder: "https://www.youtube.com/watch?v=Dn3ZMhmmzK0"
                  }
                }
                with_errors(project, :image) {
                  label {
                    text "Project Image "
                    question_tooltip "An image that is at least 450 x 400 pixels is recommended."
                    text f.attachment_field(:image)
                  }
                  text attachment_image_tag(project, :image, class: "project-image")
                }
              }
            }

            column("large-6 small-12 content-box") {
              h3 "Royalty Contract Terms"

              with_errors(project, :legal_project_owner) {
                label {
                  text "Project Owner's Legal Name "
                  question_tooltip "The name of the company, association, legal entity, or individual that owns the project and administers awards."
                  f.text_field :legal_project_owner
                }
              }

              with_errors(project, :royalty_percentage) {
                label {
                  text "Percentage of Revenue Paid to Contributor Royalties "
                  question_tooltip "The Project Owner agrees to count money customers pay either to license, or to use a hosted instance of, the Project as 'Revenue', starting from the date of this agreement. Money customers pay for consulting, training, custom development, support, and other services related to the Project does not count as Revenue."
                  f.text_field :royalty_percentage, placeholder: "5%"
                }
              }

              with_errors(project, :maximum_royalties_per_quarter) {
                label {
                  text "Maximum Royalty Amount Awarded Per Quarter"
                  f.text_field :maximum_royalties_per_quarter, placeholder: "100000"
                }
              }

              with_errors(project, :minimum_revenue) {
                label {
                  text "Minimum Revenue Collected Before Paying Contributor Royalties "
                  question_tooltip "The Project Owner agrees to begin paying Royalties once Revenue reaches the minimum revenue amount on the Award Form."
                  f.text_field :minimum_revenue, placeholder: "100"
                }
              }

              with_errors(project, :minimum_payment) {
                label {
                  text "Contributor Minimum Payment Amount "
                  question_tooltip "Once Revenue reaches the minimum revenue amount the Project Owner agrees to pay the Contributor Royalties on demand, as long as the Project Owner owes the Contributor at least the minimum payment amount."
                  f.text_field :minimum_payment, placeholder: "25"
                }
              }

              with_errors(project, :exclusive_contributions) {
                label {
                  f.check_box :exclusive_contributions
                  text "Contributions are exclusive to this project "
                  question_tooltip "When contributions are exclusive contributors may not gives others license for their contributions."
                }
              }

              with_errors(project, :business_confidentiality) {
                label {
                  f.check_box :business_confidentiality
                  text "Require business confidentiality "
                  question_tooltip "If the project requires business confidentiality, contributors agree to keep information about this agreement, other contributions to the project, royalties awarded for other contributions, revenue received, royalties paid, and all other unpublished information about the business, plans, and customers of the Project secret."
                }
              }

              with_errors(project, :project_confidentiality) {
                label {
                  f.check_box :project_confidentiality
                  text "Require project confidentiality "
                  question_tooltip "If project requires project confidentiality, contributors agree to keep copies of their contributions, copies of other materials contributed to the Project, and information about their content and purpose secret."
                }
              }
            }
          }

          div(class: "award-types") {
            row {
              column("small-4") {
                text "Award Names"
              }
              column("small-2") {
                text "Amount "
                question_tooltip "The number of coins a contributor will receive from this award. It cannot be changed after awards of this type have been issued."
              }
              column("small-3") {
                text "Community Awardable "
                question_tooltip "Check this box if you want people on your team to be able to award others. Otherwise only the project owner can send awards."
              }
              column("small-2") {
                text "Remove "
                question_tooltip "Award type cannot be changed after awards have been issued."
              }
              column("small-1") {}
            }

            project.award_types.build(amount: 0) unless project.award_types.select { |award_type| award_type.amount == 0 }.present?
            f.fields_for(:award_types) do |ff|
              row(class: "award-type-row#{ff.object.amount == 0 ? " hide award-type-template" : ""}") {
                ff.hidden_field :id
                ff.hidden_field :_destroy, 'data-destroy': ''
                column("small-4") {
                  ff.text_field :name
                }
                column("small-2") {
                  readonly = !ff.object&.modifiable?
                  if readonly
                    tooltip("Award types' amounts can't be modified if there are existing awards", if: readonly) do
                      ff.text_field :amount, type: :number, class: 'text-right', readonly: readonly
                    end
                  else
                    ff.text_field :amount, type: :number, class: 'text-right', readonly: readonly
                  end
                }
                column("small-3", class: "text-center") {
                  ff.check_box :community_awardable
                }
                column("small-2", class: "text-center") {
                  if ff.object&.modifiable?
                    a("×", href: "#", 'data-mark-and-hide': '.award-type-row', class: "close")
                  else
                    text "(#{pluralize(ff.object.awards.count, "award")} sent)"
                  end
                }
                column("small-1") {}
              }
            end
          }
          row(class: "add-award-type") {
            column {
              p { a("+ add award type", href: "#", 'data-duplicate': '.award-type-template') }
            }
          }

          full_row {
            with_errors(project, :public) {
              label {
                f.check_box :public
                text " Set project as publicly visible on CoMakery "
                question_tooltip "Decide whether or not to display this project in the CoMakery project index"
              }
            }
            f.submit "Save", class: buttonish(:expand)
          }
        end
      end

      def ethereum_beta(form)
        if current_account.slack_auth.slack_team_ethereum_enabled?
          with_errors(project, :ethereum_enabled) {
            label {
              form.check_box :ethereum_enabled, disabled: project.ethereum_enabled
              text " Publish to Ethereum Blockchain "
              question_tooltip "WARING: This is irreversible.
                      This will issue blockchain tokens for all existing and
                      future awards for users with ethereum accounts.
                      This information is public with anonymized account names
                      and cannot be revoked."
            }
          }
        else
          label {
            link_to 'Contact us', 'mailto:hello@comakery.com'
            text " if you'd like to join the Ξthereum blockchain beta for project coins"
          }
          br
        end
      end
    end
  end
end
