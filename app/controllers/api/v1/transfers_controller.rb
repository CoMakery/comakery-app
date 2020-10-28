class Api::V1::TransfersController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::RequiresAnAuthorization
  include Api::V1::Concerns::RequiresSignature
  include Api::V1::Concerns::RequiresWhitelabelMission

  before_action :verify_decimal_params_precision, only: :create
  before_action :verify_total_amount, only: :create

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

    award.name = award.transfer_type.name.titlecase
    award.issuer = project.account
    award.account = whitelabel_mission.managed_accounts.find_by!(managed_account_id: params.fetch(:body, {}).fetch(:data, {}).fetch(:transfer, {}).fetch(:account_id, {}))
    award.status = :accepted

    award.why = '—'
    award.requirements = '—'
    award.description ||= ''

    if award.save
      @transfer = award

      render 'show.json', status: :created
    else
      @errors = award.errors

      render 'api/v1/error.json', status: :bad_request
    end
  end

  # DELETE /api/v1/accounts/1/follows/1
  def destroy
    if transfer.update(status: :cancelled)
      render 'show.json', status: :ok
    else
      @errors = transfer.errors

      render 'api/v1/error.json', status: :bad_request
    end
  end

  private

    def project
      @project ||= project_scope.find(params[:project_id])
    end

    def transfers
      @transfers ||= paginate(project.awards.completed_or_cancelled.includes(:account, :latest_blockchain_transaction))
    end

    def transfer
      @transfer ||= project.awards.completed_or_cancelled.find(params[:id])
    end

    def transfer_params
      params.fetch(:body, {}).fetch(:data, {}).fetch(:transfer, {}).permit(
        :amount,
        :quantity,
        :total_amount,
        :transfer_type_id,
        :description
      )
    end

    def verify_decimal_params_precision # rubocop:todo Metrics/CyclomaticComplexity
      a = Award.new

      a.errors[:amount] << "has incorrect precision (should be #{project.token&.decimal_places.to_i})" if transfer_params[:amount] != helpers.number_with_precision(transfer_params[:amount], precision: project.token&.decimal_places.to_i)

      a.errors[:total_amount] << "has incorrect precision (should be #{project.token&.decimal_places.to_i})" if transfer_params[:total_amount] != helpers.number_with_precision(transfer_params[:total_amount], precision: project.token&.decimal_places.to_i)

      a.errors[:quantity] << "has incorrect precision (should be #{Award::QUANTITY_PRECISION})" if transfer_params[:quantity] != helpers.number_with_precision(transfer_params[:quantity], precision: Award::QUANTITY_PRECISION)

      unless a.errors.empty?
        @errors = a.errors

        render 'api/v1/error.json', status: :bad_request
      end
    end

    def verify_total_amount # rubocop:todo Metrics/CyclomaticComplexity
      a = Award.new
      calculated_total_amount = (BigDecimal(transfer_params[:amount] || 0) * BigDecimal(transfer_params[:quantity] || 0)).to_s

      a.errors[:total_amount] << "doesn't equal quantity times amount, possible multiplication error" if transfer_params[:total_amount] != helpers.number_with_precision(calculated_total_amount, precision: project.token&.decimal_places.to_i)

      unless a.errors.empty?
        @errors = a.errors

        render 'api/v1/error.json', status: :bad_request
      end
    end
end
