# Used for getting ActiveStorage attachment as image rails path with optional fallback
# Arguments:
# Required: :attachment - ActiveStorage attachment instance, i.e.: account.image
# Optional: :fallback   - Rails asset path, i.e.: asset_path('default_image.png')

class GetImagePath
  include Interactor::Organizer

  organize Attachment::SetFallbackPath,
           Attachment::GetPath
end
