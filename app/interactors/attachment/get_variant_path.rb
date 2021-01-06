# Used for getting ActiveStorage attachment variation as image rails path
# Arguments:
# Required: :variant - ActiveStorage attachment variation instance, i.e.: account.image.variant(...)

module Attachment
  class GetVariantPath
    include Interactor
    include Rails.application.routes.url_helpers

    delegate :variant, to: :context

    def call
      context.fail!(message: 'There is no attachment') if variant.blank?

      context.path = rails_representation_url(variant, only_path: true)
    end
  end
end
