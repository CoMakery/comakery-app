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
              with_errors(project, :tracker) {
                label {
                  i(class: "fa fa-tasks")
                  text " Project Tracker"
                  f.text_field :tracker, placeholder: "https://pivotaltracker.com"
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
              with_errors(project, :public) {
                label {
                  f.check_box :public
                  text " Set project as public (display in CoMakery index)"
                }
              }
            }
            column("large-6 small-12") {
              with_errors(project, :image) {
                label {
                  text "Project Image (At least 450x400 px)"
                  text f.attachment_field(:image)
                }
                text attachment_image_tag(project, :image, class: "project-image")
              }
            }
          }

          row {
            column("small-4", class: "") {
              text "Award Names"
            }
            column("small-2", class: "") {
              text "Coin Value"
            }
            column("small-2", class: "") {
              text "Community Awardable "
              question_tooltip("Check this box if you want people on your team to be able to award others. Otherwise only the project owner can send awards.")
            }
            column("small-4", class: "") {
            }
          }
          div(class: "award-types") {
            project.award_types.build(amount: 0) unless project.award_types.select{|award_type|award_type.amount == 0}.present?
            f.fields_for(:award_types) do |ff|
              row(class: "award-type-row#{ff.object.amount == 0 ? " hide award-type-template" : ""}") {
                ff.hidden_field :id
                ff.hidden_field :_destroy, 'data-destroy': ''
                column("small-4") {
                  ff.text_field :name
                }
                column("small-2") {
                  disabled = !ff.object&.modifiable?
                  if disabled
                    tooltip("Award types' amounts can't be modified if there are existing awards", if: disabled) do
                      ff.text_field :amount, type: :number, class: 'text-right', disabled: disabled
                    end
                  else
                    ff.text_field :amount, type: :number, class: 'text-right', disabled: disabled
                  end
                }
                column("small-2", class: "text-center") {
                  ff.check_box :community_awardable
                }
                column("small-4") {
                  if ff.object&.modifiable?
                    a("×", href: "#", 'data-mark-and-hide': '.award-type-row', class: "close")
                  else
                    text "(#{pluralize(ff.object.awards.count, "award")} sent)"
                  end
                }
              }
            end
          }

          row {
            p { a("+ add award type", href: "#", 'data-duplicate': '.award-type-template') }
          }
          row {
            f.submit "Save", class: buttonish(:small, :expand)
          }
        end
      end
    end
  end
end
