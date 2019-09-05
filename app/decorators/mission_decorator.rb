class MissionDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  def header_props
    {
      name: name,
      image_url: helpers.attachment_url(self, :logo, :fill, 1000, 1000),
      url: mission_path(self)
    }
  end
end
