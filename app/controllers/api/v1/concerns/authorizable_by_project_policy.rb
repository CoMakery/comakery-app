module Api::V1::Concerns::AuthorizableByProjectPolicy
  extend ActiveSupport::Concern
  include Api::V1::Concerns::Authorizable

  included do
    before_action :authorize_by_project_policy

    def authorize_by_project_policy
      authorize! if policy(project).edit?
    end
  end
end
