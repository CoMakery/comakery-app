class SendInvite
  include Interactor

  delegate :params, :whitelabel_mission, :project, to: :context

  def call
    account = GetAccount.call(whitelabel_mission: whitelabel_mission, email: params[:email]).account

    if account.blank?
      context.fail!(errors: ['Email is invalid']) unless email_valid?
      create_project_role_invite
    else
      project_role = project.project_roles.find_by(account: account)

      if project_role.present?
        context.fail!(errors: ["User already has #{project_role.role} permissions for this project. " \
                               'You can update their role with the action menu on this Accounts page'])
      end

      create_project_role(account)
    end
  end

  private

    def create_project_role_invite
      project_role = project.project_roles.new(role: params[:role])
      project_role.new_invite(email: params[:email], force_email: true)

      if project_role.save
        UserMailer.send_invite_to_platform(project_role).deliver_now
      else
        context.fail!(errors: project_role.errors.full_messages)
      end
    end

    def create_project_role(account)
      project_role = project.project_roles.new(account: account, role: params[:role])

      if project_role.save
        UserMailer.send_invite_to_project(project_role).deliver_now
      else
        context.fail!(errors: project_role.errors.full_messages)
      end
    end

    def email_valid?
      EmailValidator.new(params[:email]).valid?
    end
end
