module Views
  module Projects
    class Form < Views::Base
      needs :project, :slack_channels

      def content
        form_for project do |f|
          row {
            with_errors(project, :title) {
              label {
                text "Title"
                f.text_field :title
              }
            }
            with_errors(project, :description) {
              label {
                text "Description"
                f.text_field :description
              }
            }
            with_errors(project, :tracker) {
              label {
                text "Project Tracker"
                f.text_field :tracker, placeholder: "https://pivotaltracker.com"
              }
            }
            with_errors(project, :slack_channel) {
              label {
                text "Slack Channel"
                options = capture do
                  options_for_select([[nil, nil]].concat(slack_channels), selected: project.slack_channel)
                end
                select_tag "project[slack_channel]", options, html: {id: "project_slack_channel"}
              }
            }
            with_errors(project, :image) {
              label {
                text "Project Image (A large, roughly square image works best)"
                text f.attachment_field(:image)
              }
              text attachment_image_tag(project, :image, class: "project-image")
            }
            with_errors(project, :public) {
              label {
                f.check_box :public
                text " Set project as public (display in CoMakery index)"
              }
            }
          }

          row {
            column("small-4", class: "text-center") {
              text "Award Names"
            }
            column("small-2", class: "text-center") {
              text "Coin Value"
            }
            column("small-2", class: "text-center") {
              text "Community Awardable "
              helpful_tooltip("Check this box if you want people on your team to be able to award others. Otherwise only the project owner can send awards.")
            }
            column("small-4", class: "text-center") {
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
                  row {
                    column("small-10") { ff.text_field :amount, type: :number, class: 'text-right', disabled: disabled }
                    column("small-2") { helpful_tooltip("Award types' amounts can't be modified if there are existing awards", ) if disabled }
                  }
                }
                column("small-2", class: "text-center") {
                  ff.check_box :community_awardable
                }
                column("small-4") {
                  if ff.object&.modifiable?
                    a("×", href: "#", 'data-mark-and-hide': '.award-type-row')
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
