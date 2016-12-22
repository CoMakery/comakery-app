module Views
  module Projects
    class Form < Views::Base
      needs :project, :slack_channels

      def content
        form_for project do |f|
          div(class: 'content-box') {
            div(class: 'legal-box-header') {
              h3 "Project Settings"
            }
            row {

              column("large-6 small-12") {
                with_errors(project, :title) {
                  label {
                    text "Title"
                    f.text_field :title
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
                  }
                  link_to("Styling with Markdown is Supported", "https://guides.github.com/features/mastering-markdown/", class: "help-text float-right")
                }
                br
                with_errors(project, :public) {
                  label {
                    f.check_box :public
                    text " Set project as publicly visible on CoMakery "
                    question_tooltip "Decide whether or not to display this project in the CoMakery project index"
                  }
                }
              }

              column("large-6 small-12") {
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

          }

          div(class: 'content-box') {
            row {

              column("large-6 small-12") {
                div(class: 'legal-box-header') {
                  h3 "General Legal Terms"
                  i(class: "fa fa-lock") if project.legal_terms_finalized?
                }
                with_errors(project, :legal_project_owner) {
                  label {
                    text "Project Owner's Legal Name "
                    question_tooltip "The name of the company, association, legal entity, or individual that owns the project and administers awards."
                    f.text_field :legal_project_owner, disabled: project.legal_terms_finalized?
                  }
                }


                with_errors(project, :exclusive_contributions) {
                  label {
                    f.check_box :exclusive_contributions, disabled: project.legal_terms_finalized?
                    text "Contributions are exclusive to this project "
                    question_tooltip "When contributions are exclusive contributors may not gives others license for their contributions."
                  }
                }

                with_errors(project, :require_confidentiality) {
                  label {
                    f.check_box :require_confidentiality, disabled: project.legal_terms_finalized?
                    text "Require project and business confidentiality "
                    question_tooltip "If project requires project confidentiality contributors agree to keep information about this agreement, other contributions to the Project, royalties awarded for other contributions, revenue received, royalties paid to the contributors and others, and all other unpublished information about the business, plans, and customers of the Project secret. Contributors also agree to keep copies of their contributions, copies of other materials contributed to the Project, and information about their content and purpose secret."
                  }
                }

              }
            }
          }
          div(class: 'content-box') {
            row {

              column("large-6 small-12") {
                div(class: 'legal-box-header') {
                  h3 "Award Terms"
                  i(class: "fa fa-lock") if project.legal_terms_finalized?
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
                             {selected: project.payment_type, include_blank: false},
                             disabled: project.legal_terms_finalized?
                    )
                  }
                }
                with_errors(project, :maximum_coins) {
                  label {
                    text "Maximum Unpaid Balance"
                    question_tooltip "Select it carefully,
                      it cannot be changed after it has been set.
                      For royalties this is the maximum amount of unpaid royalties.
                      For project coins this is the maximum number of project coins that can be issued.
                      When royalties are paid or project coins are burned they are not included in this total.
                      Select a high enough number
                      so you have room for the future."
                    denomination_div f, :maximum_coins, type: "number", disabled: project.legal_terms_finalized?
                  }
                }

                with_errors(project, :maximum_royalties_per_quarter) {
                  label {
                    text "Maximum Awarded Per Quarter"
                    denomination_div f, :maximum_royalties_per_quarter,
                                     type: :number, placeholder: "12000", disabled: project.legal_terms_finalized?
                  }
                }

                ethereum_beta(f)
              }

              column("large-6 small-12") {
                div(id: 'royalty-legal-terms', class: "#{'hide' if project.project_coin?}" ) {
                  div(class: 'legal-box-header') {
                    h3 "Royalty Terms"
                    i(class: "fa fa-lock") if project.legal_terms_finalized?
                  }


                  with_errors(project, :royalty_percentage) {
                    label {
                      text "Percentage of Revenue reserved for Contributor Royalties "
                      question_tooltip "The Project Owner agrees to count money customers pay either to license, or to use a hosted instance of, the Project as 'Revenue', starting from the date of this agreement. Money customers pay for consulting, training, custom development, support, and other services related to the Project does not count as Revenue."
                      # percentage_div { f.text_field :royalty_percentage, placeholder: "5%", class: 'input-group-field' }
                      percentage_div f, :royalty_percentage, placeholder: "5%", type: :number,
                                     disabled: project.legal_terms_finalized?
                    }
                  }

                  with_errors(project, :minimum_revenue) {
                    label {
                      text "Minimum Revenue Collected Before Paying Contributor Royalties "
                      question_tooltip "The Project Owner agrees to begin paying Royalties once Revenue reaches the minimum revenue amount on the Award Form."
                      denomination_div f, :minimum_revenue, type: :number, placeholder: "100",
                                       disabled: project.legal_terms_finalized?
                    }
                  }

                  with_errors(project, :minimum_payment) {
                    label {
                      text "Contributor Minimum Payment Amount "
                      question_tooltip "Once Revenue reaches the minimum revenue amount the Project Owner agrees to pay the Contributor Royalties on demand, as long as the Project Owner owes the Contributor at least the minimum payment amount."
                      denomination_div f, :minimum_payment, type: :number, placeholder: "25",
                                       disabled: project.legal_terms_finalized?
                    }
                  }
                  h5 "Royalty Payment Schedule"
                  table(class: 'royalty-calc') {
                    thead {
                      tr {
                        th { text "Monthly Revenue" }
                        th { text "Monthly Payment" }
                        th { text "Months to Pay" }
                      }
                    }
                    tbody {
                      tr {
                        td(class: 'monthly-revenue') {}
                        td(class: 'monthly-payment') {}
                        td(class: 'months-to-pay') {}
                      }
                    }
                  }
                }
              }
            }
          }
          div(class: 'content-box') {
            div(class: "award-types") {
              div(class: 'legal-box-header') {
                h3 "Awards Offered"
              }
              row {
                column("small-4") {
                  text "Contribution Type"
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
          }

          full_row {
            f.submit "Save", class: buttonish(:expand)
          }
        end
      end

      def denomination_div(form, field_name, **opts)
        opts[:class] = "#{opts[:class]} input-group-field"
        div(class: 'input-group') {
          span(class: "input-group-label denomination") { text project.currency_denomination_explicit }
          form.text_field field_name, **opts
        }
      end

      def percentage_div(form, field_name, **opts)
        opts[:class] = "#{opts[:class]} input-group-field"

        div(class: 'input-group') {
          span(class: "input-group-label percentage") { text "%" }
          form.text_field field_name, **opts
        }
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
