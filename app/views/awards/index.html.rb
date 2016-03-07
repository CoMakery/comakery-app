module Views
  module Awards
    class Index < Views::Base
      needs :project, :awards

      def content
        h1 "Award History"
        row(class: "award-row header-row") {
          column("small-2") { div(class: "header") { text "Submitted"} }
          column("small-2") { div(class: "header") { text "Award"} }
          column("small-2") { div(class: "header") { text "Recipient"} }
          column("small-4") { div(class: "header") { text "Contribution"} }
          column("small-2") { div(class: "header") { text "Sender"} }
        }
        awards.sort_by(&:created_at).reverse.each do |award|
          row(class: "award-row") {
            column("small-2") {
              text award.created_at.strftime("%b %d, %Y")
            }
            column("small-2") {
              text number_with_delimiter(award.award_type.amount, :delimiter => ',')
            }
            column("small-2") {
              text award.recipient_slack_user_name
            }
            column("small-4") {
              div award.award_type.name
              div(class: "text-gray") { text award.description }
            }
            column("small-2") {
              text award.issuer_slack_user_name
            }
          }
        end

        br

        link_to "Back to project", project_path(project), class: buttonish
      end
    end
  end
end
