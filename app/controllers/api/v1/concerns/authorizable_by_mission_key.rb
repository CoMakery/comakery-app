module Api::V1::Concerns::AuthorizableByMissionKey
  extend ActiveSupport::Concern
  include Api::V1::Concerns::Authorizable

  included do
    before_action :authorize_by_mission_key

    def authorize_by_mission_key
      authorize! if valid_mission_key?
    end

    def valid_mission_key?
      mission_key&.present? && mission_key == request_key
    end

    def mission_key
      whitelabel_mission&.whitelabel_api_key
    end

    def request_key
      request.headers['API-Key']
    end
  end
end
