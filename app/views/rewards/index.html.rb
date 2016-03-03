module Views
  module Rewards
    class Index < Views::Base
      needs :project, :rewards

      def content
        h1 "Award History"
        row(class: "reward-row header-row") {
          column("small-2") { div(class: "header") { text "Submitted"} }
          column("small-2") { div(class: "header") { text "Award"} }
          column("small-2") { div(class: "header") { text "Recipient"} }
          column("small-4") { div(class: "header") { text "Contribution"} }
          column("small-2") { div(class: "header") { text "Sender"} }
        }
        rewards.sort_by(&:created_at).reverse.each do |reward|
          row(class: "reward-row") {
            column("small-2") {
              text reward.created_at.strftime("%b %d, %Y")
            }
            column("small-2") {
              text number_with_delimiter(reward.reward_type.amount, :delimiter => ',')
            }
            column("small-2") {
              text reward.recipient_slack_user_name
            }
            column("small-4") {
              text reward.description
            }
            column("small-2") {
              text reward.issuer_slack_user_name
            }
          }
        end

        br

        link_to "Back to project", project_path(project), class: buttonish
      end
    end
  end
end
