class SendInvite
  include Interactor

  def call
    context.fail!(errors: ['The user must have signed up to add them']) if account.blank?

    invite = context.project.project_roles.new(account: account, role: context.params[:role])

    context.fail!(errors: invite.errors.full_messages) unless invite.save
  end

  private

    def account
      if context.whitelabel_mission
        context.whitelabel_mission.managed_accounts.find_by(email: context.params[:email])
      else
        Account.find_by(email: context.params[:email], managed_mission_id: nil)
      end
    end
end
