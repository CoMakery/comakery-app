class MissionDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  def header_props
    {
      name: name,
      image_url: logo_path,
      url: mission_path(self)
    }
  end

  def logo_path
    GetImageVariantPath.call(
      attachment: logo,
      resize_to_fill: [1000, 1000]
    ).path
  end
end
