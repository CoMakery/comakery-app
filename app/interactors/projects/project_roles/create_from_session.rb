module Projects
  module ProjectRoles
    class CreateFromSession
      include Interactor

      delegate :project, :project_invite, :whitelabel_mission, to: :context

      def call
        if project.invites.pending.exists?(project_invite.id)
          project_role = project.project_roles.new(account: account, role: project_invite.role)

          if project_role.save
            project_invite.update(accepted: true)

            session.delete(:project_invite)
          else
            context.fail!(message: project_role.errors.full_messages)
          end
        end
      end

      private

        def account
          if whitelabel_mission
            whitelabel_mission.managed_accounts.find_by(email: email)
          else
            Account.find_by(email: email, managed_mission_id: nil)
          end
        end
    end
  end
end
