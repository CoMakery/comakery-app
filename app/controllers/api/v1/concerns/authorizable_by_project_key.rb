module Api::V1::Concerns::AuthorizableByProjectKey
  extend ActiveSupport::Concern
  include Api::V1::Concerns::Authorizable

  included do
    before_action :authorize_by_project_key

    def authorize_by_project_key
      authorize! if valid_project_key?
    end

    def valid_project_key?
      project_key.present? && project_key == request_project_key
    end

    def project_key
      project&.api_key&.key
    end

    def request_project_key
      request.headers['API-Transaction-Key']
    end
  end
end
