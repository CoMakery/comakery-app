module Views
  module Rewards
    class Form < Views::Base
      needs :project, :reward, :rewardable_accounts

      def content
        form_for [project, reward] do |f|

        end
      end
    end
  end
end
