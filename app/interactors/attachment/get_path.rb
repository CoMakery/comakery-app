# Used for getting ActiveStorage attachment as image rails path
# Arguments:
# Required: :attachment - ActiveStorage attachment instance, i.e.: account.image

module Attachment
  class GetPath
    include Interactor
    include Rails.application.routes.url_helpers

    delegate :attachment, to: :context

    def call
      context.fail!(message: 'There is no attachment') unless attachment&.attached?

      context.path = rails_blob_path(attachment, only_path: true)
    end
  end
end
