class Api::V1::TransfersController < Api::V1::ApiController
  # GET /api/v1/projects/1/transfers
  def index
    fresh_when transfers, public: true
  end

  # GET /api/v1/projects/1/transfers/1
  def show
    fresh_when transfer, public: true
  end

  # POST /api/v1/projects/1/transfers
  def create
    award = project.default_award_type.awards.create(transfer_params)

    award.name = award.source.capitalize
    award.issuer = project.account
    award.status = :accepted

    award.why = '—'
    award.requirements = '—'
    award.description ||= '—'

    if award.save
      redirect_to api_v1_project_transfer_path(project, award)
    else
      @errors = award.errors

      render 'api/v1/error.json', status: 400
    end
  end

  # DELETE /api/v1/accounts/1/follows/1
  def destroy
    if transfer.update(status: :cancelled)
      redirect_to api_v1_project_transfer_path(project, transfer)
    else
      @errors = transfer.errors

      render 'api/v1/error.json', status: 400
    end
  end

  private

    def project
      @project ||= project_scope.find(params[:project_id])
    end

    def transfers
      @transfers ||= paginate(project.awards.completed_or_cancelled)
    end

    def transfer
      @transfer ||= project.awards.completed_or_cancelled.find(params[:id])
    end

    def transfer_params
      params.fetch(:transfer, {}).permit(
        :amount,
        :quantity,
        :source,
        :description,
        :account_id
      )
    end
end
