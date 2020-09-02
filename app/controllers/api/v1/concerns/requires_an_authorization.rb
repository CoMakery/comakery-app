module Api::V1::Concerns::RequiresAnAuthorization
  extend ActiveSupport::Concern
  include Api::V1::Concerns::Authorizable

  included do
    before_action :requires_an_authorization

    def requires_an_authorization
      unless authorized
        @errors = { authentication: 'Missing an authorization' }

        render 'api/v1/error.json', status: :unauthorized
      end
    end
  end
end
