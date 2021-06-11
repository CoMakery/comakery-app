module Projects
  module ProjectRoles
    class CreateFromSession
      include Interactor

      delegate :account, :session, to: :context

      def call
        if project.invites.pending.exists?(session[:project_invite].id)
          project_role = project.project_roles.new(account: account, role: session[:project_invite].role)

          if project_role.save
            context.project_role = project_role

            project_invite.update(accepted: true)

            session.delete(:project_invite)
          else
            context.fail!(message: project_role.errors.full_messages)
          end
        end
      end

      private

        def project
          context.project = Project.find(project_invite.invitable_id)
        end

        def project_invite
          @project_invite ||= session[:project_invite]
        end
    end
  end
end
