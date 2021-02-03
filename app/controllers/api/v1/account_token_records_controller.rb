class Api::V1::AccountTokenRecordsController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::RequiresAnAuthorization

  # GET /api/v1/tokens/:id/account_token_records
  # GET /api/v1/tokens/:id/account_token_records/?account_id=:account_id
  # GET /api/v1/tokens/:id/account_token_records/?wallet_id=:wallet_id
  def index
    fresh_when account_token_records, public: true
  end

  # POST /api/v1/tokens/:id/account_token_records
  def create
    account_token_record = account_token_records.new(account_token_record_params)
    account_token_record.account = find_account_from_body

    if account_token_record.save
      @account_token_record = account_token_record

      render 'index.json', status: :created
    else
      @errors = account_token_record.errors

      render 'api/v1/error.json', status: :bad_request
    end
  end

  # DELETE /api/v1/tokens/:id/account_token_records/?account_id=:account_id
  # DELETE /api/v1/tokens/:id/account_token_records/?wallet_id=:wallet_id
  def destroy_all
    @account_token_records = wallet_scope
    @account_token_records.destroy_all
    render 'index.json', status: :ok
  end

  private

    def account_token_records
      @account_token_records ||= paginate(collection)
    end

    def collection
      wallet_scope? ? wallet_scope : general_scope
    end

    def wallet_scope?
      params[:wallet_id].present?
    end

    def wallet_scope
      general_scope.where(wallet_id: params[:wallet_id])
    end

    def general_scope
      @general_scope ||= token.account_token_records
    end

    def token
      @token ||= Token.find(params[:token_id])
    end

    def find_account_from_body
      account_id = params.dig(:body, :data, :account_token_record, :managed_account_id)
      Account.find_by(managed_account_id: account_id)
    end

    def account_token_record_params
      params
        .fetch(:body, {})
        .fetch(:data, {})
        .fetch(:account_token_record, {})
        .permit(:max_balance, :lockup_until, :reg_group_id, :account_frozen)
    end
end
