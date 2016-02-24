module Views
  module Rewards
    class Form < Views::Base
      needs :project, :reward, :rewardable_accounts

      def content
        form_for [project, reward] do |f|
          full_row {
            with_errors(project, :account_id) {
              label {
                text "User"
                f.select(:account_id, rewardable_accounts.map{|a|[a.name, a.id]})
              }
            }
          }
          full_row {
            with_errors(project, :amount) {
              label {
                text "Amount"
                f.text_field(:amount, type: :number)
              }
            }
          }
          full_row {
            with_errors(project, :description) {
              label {
                text "Description"
                f.text_area(:description)
              }
            }
          }
          full_row {
            f.submit("Send Reward")
          }
        end
      end
    end
  end
end
