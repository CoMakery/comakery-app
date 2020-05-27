class Api::V1::AccountTokenRecordsController < Api::V1::ApiController
  before_action :set_api_v1_account_token_record, only: %i[show edit update destroy]

  # GET /api/v1/account_token_records
  # GET /api/v1/account_token_records.json
  def index
    @api_v1_account_token_records = Api::V1::AccountTokenRecord.all
  end

  # GET /api/v1/account_token_records/1
  # GET /api/v1/account_token_records/1.json
  def show; end

  # GET /api/v1/account_token_records/new
  def new
    @api_v1_account_token_record = Api::V1::AccountTokenRecord.new
  end

  # GET /api/v1/account_token_records/1/edit
  def edit; end

  # POST /api/v1/account_token_records
  # POST /api/v1/account_token_records.json
  def create
    @api_v1_account_token_record = Api::V1::AccountTokenRecord.new(api_v1_account_token_record_params)

    respond_to do |format|
      if @api_v1_account_token_record.save
        format.html { redirect_to @api_v1_account_token_record, notice: 'Account token record was successfully created.' }
        format.json { render :show, status: :created, location: @api_v1_account_token_record }
      else
        format.html { render :new }
        format.json { render json: @api_v1_account_token_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api/v1/account_token_records/1
  # PATCH/PUT /api/v1/account_token_records/1.json
  def update
    respond_to do |format|
      if @api_v1_account_token_record.update(api_v1_account_token_record_params)
        format.html { redirect_to @api_v1_account_token_record, notice: 'Account token record was successfully updated.' }
        format.json { render :show, status: :ok, location: @api_v1_account_token_record }
      else
        format.html { render :edit }
        format.json { render json: @api_v1_account_token_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/v1/account_token_records/1
  # DELETE /api/v1/account_token_records/1.json
  def destroy
    @api_v1_account_token_record.destroy
    respond_to do |format|
      format.html { redirect_to api_v1_account_token_records_url, notice: 'Account token record was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_account_token_record
      @api_v1_account_token_record = Api::V1::AccountTokenRecord.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def api_v1_account_token_record_params
      params.fetch(:api_v1_account_token_record, {})
    end
end
