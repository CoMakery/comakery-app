module Api::V1::Concerns::RequiresSignature
  extend ActiveSupport::Concern

  included do
    before_action :verify_signature

    def verify_signature
      Comakery::APISignature.new(
        params.as_json,
        request.base_url + request.path,
        request.method,
        ->(nonce) { nonce_unique?(nonce) }
      ).verify(whitelabel_mission&.whitelabel_api_public_key)
    rescue Comakery::APISignatureError => e
      @errors = { authentication: e.message }

      return render 'api/v1/error.json', status: 401
    end
  end
end
