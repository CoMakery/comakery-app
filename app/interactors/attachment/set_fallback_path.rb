# Intended to be a part of organizer call
# Just presets fallback path to context if provided

module Attachment
  class SetFallbackPath
    include Interactor

    delegate :fallback, to: :context

    def call
      context.path = fallback if fallback.present?
    end
  end
end
