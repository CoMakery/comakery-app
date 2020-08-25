module ApiAuthorizable
  extend ActiveSupport::Concern

  included do
    has_one :api_key, as: :api_authorizable, dependent: :destroy

    def regenerate_api_key
      api_key&.destroy
      create_api_key!
    end
  end
end
