# Used for produce ActiveStorage attachment variation
# Arguments:
# Required: :attachment      - ActiveStorage attachment instance, i.e.: account.image
# Optional: :resize_to_fill  - Image operation, i.e.: [100, 100]
#           :resize_to_fit   - Image operation, i.e.: [100, 100]
#           :resize_to_limit - Image operation, i.e.: [100, 100]

module Attachment
  class GetVariant
    include Interactor

    delegate :attachment, :resize_to_fill, :resize_to_fit, :resize_to_limit, to: :context

    def call
      context.fail!(message: 'There is no attachment') unless attachment&.attached?

      context.variant = attachment.variant(resize_options).processed
    end

    private

      def resize_options
        return { resize_to_fill: resize_to_fill } if resize_to_fill
        return { resize_to_fit: resize_to_fit } if resize_to_fit
        return { resize_to_limit: resize_to_limit } if resize_to_limit

        {}
      end
  end
end
