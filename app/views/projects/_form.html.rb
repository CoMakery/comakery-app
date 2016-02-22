module Views
  module Projects
    class Form < Views::Base
      needs :project

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
                f.text_field :tracker
              }
            }
            with_errors(project, :public) {
              label {
                f.check_box :public
                text " Public"
              }
            }
          }

          row {
            column("small-4") {
              text "Reward Names"
            }
            column("small-4") {
              text "Suggested Value"
            }
            column("small-4") {
            }
          }
          div(class: "reward-types") {
            project.reward_types.each do |reward_type|
              reward_type_content(reward_type)
            end
            reward_type_content(nil, "hide reward-type-template ")
          }

          row {
            p { a("+ add reward type", href:"#", 'data-duplicate': '.reward-type-template') }
          }
          row {
            f.submit "Save", class: buttonish(:small, :expand)
          }
        end
      end

      def reward_type_content(reward_type, classes="")
        row(class: "reward-type-row #{classes}") {
          hidden_field_tag :'project[reward_types_attributes][][id]', reward_type.try(:to_param)
          column("small-4") {
            text_field_tag :'project[reward_types_attributes][][name]', reward_type.try(:name)
          }
          column("small-4") {
            text_field_tag :'project[reward_types_attributes][][suggested_amount]', reward_type.try(:suggested_amount)
          }
          column("small-4") {
          }
        }
      end
    end
  end
end
