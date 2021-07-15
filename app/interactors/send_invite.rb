class SendInvite
  include Interactor

  delegate :params, :whitelabel_mission, :project, to: :context

  def call
    context.fail!(errors: ['Email is invalid']) unless email_valid?

    account ? create_project_role : create_project_role_invite
  end

  private

    def create_project_role
      project_role = project.project_roles.new(account: account, role: params[:role])

      if project_role.save
        UserMailer.send_invite_to_project(project_role).deliver_now
      else
        context.fail!(errors: project_role.errors.full_messages)
      end
    end

    def create_project_role_invite
      invite = Invite.new(
        email: params[:email],
        force_email: true,
        invitable: project.project_roles.new(role: params[:role])
      )

      invite.save!
      UserMailer.with(whitelabel_mission: whitelabel_mission).send_invite_to_platform(invite.invitable.reload).deliver_now
    end

    def email_valid?
      @email_valid ||= EmailValidator.new(params[:email]).valid?
    end

    def account
      @account ||= GetAccount.call(whitelabel_mission: whitelabel_mission, email: params[:email]).account
    end
end
