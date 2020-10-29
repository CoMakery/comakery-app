class Api::V1::AccountTransfersController < Api::V1::ApiController
  include Api::V1::Concerns::RequiresAnAuthorization
  include Api::V1::Concerns::RequiresSignature
  include Api::V1::Concerns::RequiresWhitelabelMission

  # GET /api/v1/accounts/1/transfers
  def index
    fresh_when transfers, public: true
  end

  private

    def account
      @account ||= whitelabel_mission.managed_accounts.find_by!(managed_account_id: params[:account_id])
    end

    def transfers
      awards = account.awards.completed_or_cancelled.includes(:project)
      @transfers ||= paginate(awards)
    end
end
