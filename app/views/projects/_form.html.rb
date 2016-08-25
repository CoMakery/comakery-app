module Views
  module Projects
    class Form < Views::Base
      needs :project, :slack_channels

      def content
        form_for project do |f|
          row {
            column("large-6 small-12") {
              with_errors(project, :title) {
                label {
                  text "Title"
                  f.text_field :title
                }
              }
              with_errors(project, :maximum_coins) {
                label {
                  text "Maximum Number of Awardable Coins "
                  question_tooltip("This is the maximum sum of coins
                    you can award in the life of this project.
                    Select it carefully,
                    it cannot be changed after it has been set.
                    Also select a high enough number
                    so you have room for the future.")
                  f.text_field :maximum_coins, type: "number", disabled: !project.new_record?
                }
              }
              with_errors(project, :slack_channel) {
                label {
                  i(class: "fa fa-slack")
                  text " Slack Channel "
                  question_tooltip("Select where project notifications will be sent.")
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
              }
              with_errors(project, :public) {
                label {
                  f.check_box :public
                  text " Set project as publicly visible on CoMakery "
                  question_tooltip("Decide whether or not to display this project in the CoMakery project index")
                }
              }
              if current_account.slack_auth.slack_team_ethereum_enabled?
                with_errors(project, :ethereum_enabled) {
                  label {
                    f.check_box :ethereum_enabled, disabled: project.ethereum_enabled
                    text " Publish to Ethereum Blockchain "
                    question_tooltip("WARING: This is irreversible.
                      This will issue blockchain tokens for all existing and
                      future awards for users with ethereum accounts.
                      This information is public with anonymized account names
                      and cannot be revoked.")
                  }
                }
              else
                label {
                  link_to 'contact us', 'mailto:hello@comakery.com'
                  text " if you'd like to join the Ξthereum blockchain beta"
                }
              end
            }
            column("large-6 small-12") {
              with_errors(project, :tracker) {
                label {
                  i(class: "fa fa-tasks")
                  text " Project Tracker"
                  f.text_field :tracker, placeholder: "https://trello.com/my-project"
                }
              }
              with_errors(project, :contributor_agreement_url) {
                label {
                  i(class: "fa fa-gavel")
                  text " Contributor Agreement"
                  f.text_field :contributor_agreement_url, placeholder: "https://docusign.com"
                }
              }
              with_errors(project, :video_url) {
                label {
                  i(class: "fa fa-youtube")
                  text " Video "
                  question_tooltip("A video url representing your project. Must be a Youtube url.")
                  f.text_field :video_url, placeholder: "https://www.youtube.com/watch?v=Dn3ZMhmmzK0"
                }
              }
              with_errors(project, :image) {
                label {
                  text "Project Image "
                  question_tooltip("An image that is at least 450 x 400 pixels is recommended.")
                  text f.attachment_field(:image)
                }
                text attachment_image_tag(project, :image, class: "project-image")
              }
            }
          }

          div(class: "award-types") {
            row {
              column("small-4") {
                text "Award Names"
              }
              column("small-2") {
                text "Coin Value "
                question_tooltip("The number of coins a contributor will receive from this award. It cannot be changed after awards of this type have been issued.")
              }
              column("small-3") {
                text "Community Awardable "
                question_tooltip("Check this box if you want people on your team to be able to award others. Otherwise only the project owner can send awards.")
              }
              column("small-2") {
                text "Remove "
                question_tooltip("Award type cannot be changed after awards have been issued.")
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
            f.submit "Save", class: buttonish(:expand)
          }
        end
      end
    end
  end
end
