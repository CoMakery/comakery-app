class SendInvite
  include Interactor

  delegate :params, :whitelabel_mission, :project, to: :context

  def call
    account = GetAccount.call(whitelabel_mission: whitelabel_mission, email: params[:email]).account

    if account.blank?
      context.fail!(errors: ['Email is invalid']) unless email_valid?

      project_invite = project.invites.find_by(email: params[:email])

      context.fail!(errors: ['Invite is already sent']) if project_invite.present?

      create_project_invite
    else
      project_role = project.project_roles.find_by(account: account)

      if project_role.present?
        context.fail!(errors: ["User already has #{project_role.role} permissions for this project. " \
                               'You can update their role with the action menu on this Accounts page'])
      end

      create_project_role
    end
  end

  private

    def create_project_invite
      project_invite = project.invites.new(email: params[:email], role: params[:role])

      if project_invite.save
        UserMailer.send_invite_to_platform(
          params[:email],
          project_invite.token,
          project,
          params[:role],
          domain_name
        ).deliver_now
      else
        context.fail!(errors: project_invite.errors.full_messages)
      end
    end

    def create_project_role
      project_role = project.project_roles.new(account: account, role: params[:role])

      if project_role.save
        UserMailer.send_invite_to_project(
          account.email,
          project,
          params[:role],
          domain_name
        ).deliver_now
      else
        context.fail!(errors: project_role.errors.full_messages)
      end
    end

    def email_valid?
      EmailValidator.new(params[:email]).valid?
    end

    def domain_name
      if whitelabel_mission
        whitelabel_mission.whitelabel_domain
      else
        ENV['APP_HOST']
      end
    end
end
