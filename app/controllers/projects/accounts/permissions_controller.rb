module Projects
  module Accounts
    class PermissionsController < ApplicationController
      skip_after_action :verify_authorized, :verify_policy_scoped
      before_action :find_project
      before_action :find_interest

      def show
        respond_to do |format|
          format.html { redirect_to wallets_path }
          format.json do
            content = render_to_string(
              partial: 'projects/accounts/permissions/form',
              formats: :html,
              layout: false,
              locals: { interest: @interest }
            )
            render json: { content: content }, status: :ok
          end
        end
      end

      def update
        authorize @project, :update_permissions?

        respond_to do |format|
          if @interest.update(role: params[:interest][:role])
            format.json { render json: { message: 'Permissions successfully updated' }, status: :ok }
          else
            format.json { render json: { errors: @interest.errors.full_messages }, status: :unprocessable_entity }
          end
        end
      end

      private

        def find_project
          @project = Project.find(params[:project_id])
        end

        def find_interest
          @interest = Interest.find(params[:id])
        end
    end
  end
end
