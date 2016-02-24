module Views
  module Rewards
    class New < Views::Base
      needs :project, :reward, :rewardable_accounts

      def content
        full_row { h1 "Send Reward - #{project.title}" }
        render partial: "form", locals: {project: project, reward: reward, rewardable_accounts: rewardable_accounts}
      end
    end
  end
end
