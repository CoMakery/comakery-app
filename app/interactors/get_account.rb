module Invites
  class GetAccount
    include Interactor

    delegate :whitelabel_mission, :email, to: :context

    def call
      if whitelabel_mission
        context.account = whitelabel_mission.managed_accounts.find_by(email: email)
      else
        context.account = Account.find_by(email: email, managed_mission_id: nil)
      end
    end
  end
end
