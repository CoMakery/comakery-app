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
                text "Public"
                f.check_box :public
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
            f.fields_for :reward_types do |ff|
              row {
                column("small-4") {
                  ff.text_field :name
                }
                column("small-4") {
                  ff.text_field :suggested_amount
                }
                column("small-4") {
                }
              }
            end
          }
          row {
            f.submit "Save", class: buttonish(:small, :expand)
          }
        end
      end
    end
  end
end
