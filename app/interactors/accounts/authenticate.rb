module Accounts
  class Authenticate
    include Interactor

    def call
      if account&.password_digest && account&.authenticate(context.password)
        context.account = account
      else
        context.fail!
      end
    end

    private

      def account
        if context.whitelabel_mission
          context.whitelabel_mission.managed_accounts.find_by(email: context.email)
        else
          Account.find_by(email: context.email, managed_mission_id: nil)
        end
      end
  end
end
