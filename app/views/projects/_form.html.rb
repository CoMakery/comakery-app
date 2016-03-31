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
              with_errors(project, :description) {
                label {
                  text "Description"
                  f.text_area :description
                }
              }
              with_errors(project, :slack_channel) {
                label {
                  i(class: "fa fa-slack")
                  text " Slack Channel"
                  options = capture do
                    options_for_select([[nil, nil]].concat(slack_channels), selected: project.slack_channel)
                  end
                  select_tag "project[slack_channel]", options, html: {id: "project_slack_channel"}
                }
              }
              with_errors(project, :maximum_coins) {
                label {
                  text "Maximum number of awardable coins"
                  f.text_field :maximum_coins, type: "number", disabled: !project.new_record?
                }
              }
              with_errors(project, :public) {
                label {
                  f.check_box :public
                  text " Set project as public (display in CoMakery index)"
                }
              }
            }
            column("large-6 small-12") {
              with_errors(project, :tracker) {
                label {
                  i(class: "fa fa-tasks")
                  text " Project Tracker"
                  f.text_field :tracker, placeholder: "https://pivotaltracker.com"
                }
              }
              with_errors(project, :image) {
                label {
                  text "Project Image (At least 450x400 px)"
                  text f.attachment_field(:image)
                }
                text attachment_image_tag(project, :image, class: "project-image")
              }
            }
          }

          div(class: "award-types") {
            row {
              column("small-4", class: "") {
                label "Award Names"
              }
              column("small-2", class: "") {
                label "Coin Value"
              }
              column("small-6", class: "") {
                label {
                  text "Community Awardable "
                  question_tooltip("Check this box if you want people on your team to be able to award others. Otherwise only the project owner can send awards.")
                }
              }
            }

            project.award_types.build(amount: 0) unless project.award_types.select{|award_type|award_type.amount == 0}.present?
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
                column("small-3") {
                  if ff.object&.modifiable?
                    a("×", href: "#", 'data-mark-and-hide': '.award-type-row', class: "close")
                  else
                    text "(#{pluralize(ff.object.awards.count, "award")} sent)"
                  end
                }
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
