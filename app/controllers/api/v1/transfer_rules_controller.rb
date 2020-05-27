class Api::V1::TransferRulesController < Api::V1::ApiController
  before_action :set_api_v1_transfer_rule, only: %i[show edit update destroy]

  # GET /api/v1/transfer_rules
  # GET /api/v1/transfer_rules.json
  def index
    @api_v1_transfer_rules = Api::V1::TransferRule.all
  end

  # GET /api/v1/transfer_rules/1
  # GET /api/v1/transfer_rules/1.json
  def show; end

  # GET /api/v1/transfer_rules/new
  def new
    @api_v1_transfer_rule = Api::V1::TransferRule.new
  end

  # GET /api/v1/transfer_rules/1/edit
  def edit; end

  # POST /api/v1/transfer_rules
  # POST /api/v1/transfer_rules.json
  def create
    @api_v1_transfer_rule = Api::V1::TransferRule.new(api_v1_transfer_rule_params)

    respond_to do |format|
      if @api_v1_transfer_rule.save
        format.html { redirect_to @api_v1_transfer_rule, notice: 'Transfer rule was successfully created.' }
        format.json { render :show, status: :created, location: @api_v1_transfer_rule }
      else
        format.html { render :new }
        format.json { render json: @api_v1_transfer_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api/v1/transfer_rules/1
  # PATCH/PUT /api/v1/transfer_rules/1.json
  def update
    respond_to do |format|
      if @api_v1_transfer_rule.update(api_v1_transfer_rule_params)
        format.html { redirect_to @api_v1_transfer_rule, notice: 'Transfer rule was successfully updated.' }
        format.json { render :show, status: :ok, location: @api_v1_transfer_rule }
      else
        format.html { render :edit }
        format.json { render json: @api_v1_transfer_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/v1/transfer_rules/1
  # DELETE /api/v1/transfer_rules/1.json
  def destroy
    @api_v1_transfer_rule.destroy
    respond_to do |format|
      format.html { redirect_to api_v1_transfer_rules_url, notice: 'Transfer rule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_transfer_rule
      @api_v1_transfer_rule = Api::V1::TransferRule.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def api_v1_transfer_rule_params
      params.fetch(:api_v1_transfer_rule, {})
    end
end
