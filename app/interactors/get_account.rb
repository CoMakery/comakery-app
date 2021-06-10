class GetAccount
  include Interactor

  delegate :whitelabel_mission, :email, to: :context

  def call
    context.account = if whitelabel_mission
      whitelabel_mission.managed_accounts.find_by(email: email)
    else
      Account.find_by(email: email, managed_mission_id: nil)
    end
  end
end
