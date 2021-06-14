module Projects
  module ProjectRoles
    class CreateFromInvite
      include Interactor

      delegate :account, :project_invite, to: :context

      def call
        if project_invite && project.invites.pending.include?(project_invite)
          project_role = project.project_roles.new(account: account, role: project_invite.role)

          if project_role.save
            context.project_role = project_role

            project_invite.update(accepted: true)
          else
            context.fail!(message: project_role.errors.full_messages)
          end
        end
      end

      private

       def project
         Project.find(project_invite.invitable_id)
       end
    end
  end
end
