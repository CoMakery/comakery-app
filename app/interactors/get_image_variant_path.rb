# Used for getting ActiveStorage attachment variation as image rails path
# Arguments:
# Required: :attachment      - ActiveStorage attachment instance, i.e.: account.image
# Optional: :fallback        - Rails asset path, i.e.: asset_path('default_image.png')
#           :resize_to_fill  - Image operation, i.e.: [100, 100]
#           :resize_to_fit   - Image operation, i.e.: [100, 100]
#           :resize_to_limit - Image operation, i.e.: [100, 100]

class GetImageVariantPath
  include Interactor::Organizer

  organize Attachment::SetFallbackPath,
           Attachment::GetVariant,
           Attachment::GetVariantPath
end
