class Api::V1::AccountTokenRecordsController < Api::V1::ApiController
  # GET /api/v1/projects/1/account_token_records
  def index
    fresh_when account_token_records, public: true
  end

  # GET /api/v1/projects/1/account_token_records/1
  def show
    fresh_when account_token_record, public: true
  end

  # POST /api/v1/projects/1/account_token_records
  def create
    account_token_record = project.token.account_token_records.new(account_token_record_params)
    account_token_record.account = Account.find(
      params.fetch(:body, {}).fetch(:data, {}).fetch(:account_token_record, {}).fetch(:account_id, nil)
    )

    if account_token_record.save
      @account_token_record = account_token_record

      render 'show.json', status: 201
    else
      @errors = account_token_record.errors

      render 'api/v1/error.json', status: 400
    end
  end

  # DELETE /api/v1/projects/1/account_token_records/1
  def destroy
    account_token_record.destroy
    render 'index.json', status: 200
  end

  private

    def project
      @project ||= project_scope.find(params[:project_id])
    end

    def account_token_records
      @account_token_records ||= paginate(project.token.account_token_records)
    end

    def account_token_record
      @account_token_record ||= project.token.account_token_records.find(params[:id])
    end

    def account_token_record_params
      params.fetch(:body, {}).fetch(:data, {}).fetch(:account_token_record, {}).permit(
        :max_balance,
        :lockup_until,
        :reg_group_id,
        :account_frozen
      )
    end
end
