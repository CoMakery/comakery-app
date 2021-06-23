class InvitesController < ApplicationController
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
    @invite = current_account.invites.accepted.find(id: params[:id])

    clean_session_invite_id
    redirect_to project_dashboard_accounts_path(@invite.invitable.project), flash: { notice: "You have successfully joined the project with the #{@invite.invitable.role} role" }
  end

  private

    def accept_invite
      if @invite.update(account: current_account, accepted: true)
        redirect_to invite_redirect_path(@invite)
      else
        redirect_to my_account_path, flash: { error: @invite.errors.full_messages.join(', ') }
      end
    end

    def set_session_invite_id
      session[:invite_id] = invite_id
    end

    def clean_session_invite_id
      session.delete(:invite_id)
    end
end
