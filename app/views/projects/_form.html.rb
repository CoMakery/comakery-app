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
            with_errors(project, :image) {
              label {
                text "Project Image"
                text f.attachment_field(:image)
              }
              text attachment_image_tag(project, :image, class: "project-image")
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
            with_errors(project, :public) {
              label {
                f.check_box :public
                text " Set project as public (display in CoMakery index)"
              }
            }
          }

          row {
            column("small-4") {
              text "Award Names"
            }
            column("small-4") {
              text "Suggested Value"
            }
            column("small-4") {
            }
          }
          div(class: "award-types") {
            project.award_types.each do |award_type|
              award_type_content(award_type)
            end
            award_type_content(nil, "hide award-type-template")
          }

          row {
            p { a("+ add award type", href: "#", 'data-duplicate': '.award-type-template') }
          }
          row {
            f.submit "Save", class: buttonish(:small, :expand)
          }
        end
      end

      def award_type_content(award_type, classes="")
        row(class: "award-type-row #{classes}") {
          hidden_field_tag :'project[award_types_attributes][][id]', award_type.try(:to_param)
          hidden_field_tag :'project[award_types_attributes][][_destroy]', award_type.try(:_destroy), 'data-destroy': ''
          column("small-4") {
            text_field_tag :'project[award_types_attributes][][name]', award_type.try(:name)
          }
          column("small-4") {
            text_field_tag :'project[award_types_attributes][][amount]', award_type.try(:amount), type: :number
          }
          column("small-4") {
            if award_type && award_type.awards.count > 0
              text "(#{pluralize(award_type.awards.count, "award")} sent)"
            else
              a("×", href: "#", 'data-mark-and-hide': '.award-type-row')
            end
          }
        }
      end
    end
  end
end
