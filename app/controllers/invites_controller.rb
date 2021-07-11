class InvitesController < ApplicationController
  skip_before_action :require_login_strict
  skip_before_action :require_login, only: %i[show]
  skip_after_action :verify_authorized

  # GET /invites/1
  def show
    @invite = Invite.pending.find_by!(token: params[:id])

    if current_account
      accept_invite
    else
      set_session_invite_id
      redirect_to new_account_path
    end
  end

  # GET /invites/1/redirect
  def redirect
    @invite = current_account.invites.where(accepted: true).find(params[:id])

    clean_session_invite_id
    redirect_to project_dashboard_accounts_path(@invite.invitable.project), flash: { notice: "You have successfully joined the project with the #{@invite.invitable.role} role" }
  end

  private

    def accept_invite
      if @invite.update(account: current_account, accepted: true)
        redirect_to redirect_invite_path(@invite)
      else
        redirect_to account_path, flash: { error: @invite.errors.full_messages.join(', ') }
      end
    end

    def set_session_invite_id
      session[:invite_id] = @invite.id
    end

    def clean_session_invite_id
      session.delete(:invite_id)
    end
end
