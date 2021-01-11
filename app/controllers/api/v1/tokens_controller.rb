class Api::V1::TokensController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::RequiresAnAuthorization
  include Api::V1::Concerns::RequiresSignature
  include Api::V1::Concerns::RequiresWhitelabelMission

  def index
    fresh_when tokens, public: true
  rescue ActiveRecord::StatementInvalid
    @errors = error_operator_matcher
    render 'api/v1/error.json', status: :bad_request
  end

  private

    def tokens
      @tokens ||= Token.ransack(params[:q]).result
    end

    def error_operator_matcher
      { q: 'No operator matches the given name and argument types.' }
    end
end
