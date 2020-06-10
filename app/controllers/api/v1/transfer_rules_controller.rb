class Api::V1::TransferRulesController < Api::V1::ApiController
  skip_before_action :verify_signature
  skip_before_action :verify_public_key
  skip_before_action :allow_only_whitelabel
  before_action :verify_public_key_or_policy

  # GET /api/v1/projects/1/transfer_rules
  def index
    fresh_when transfer_rules, public: true
  end

  # GET /api/v1/projects/1/transfer_rules/1
  def show
    fresh_when transfer_rule, public: true
  end

  # POST /api/v1/projects/1/transfer_rules
  def create
    transfer_rule = project.token.transfer_rules.create(transfer_rule_params)

    if transfer_rule.save
      @transfer_rule = transfer_rule

      render 'show.json', status: 201
    else
      @errors = transfer_rule.errors

      render 'api/v1/error.json', status: 400
    end
  end

  # DELETE /api/v1/projects/1/transfer_rules/1
  def destroy
    transfer_rule.destroy
    render 'index.json', status: 200
  end

  private

    def project
      @project ||= project_scope.find(params[:project_id])
    end

    def transfer_rules
      @transfer_rules ||= paginate(project.token.transfer_rules)
    end

    def transfer_rule
      @transfer_rule ||= project.token.transfer_rules.find(params[:id])
    end

    def transfer_rule_params
      params.fetch(:body, {}).fetch(:data, {}).fetch(:transfer_rule, {}).permit(
        :sending_group_id,
        :receiving_group_id,
        :lockup_until
      )
    end
end
