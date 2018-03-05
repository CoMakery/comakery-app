module ApplicationHelper
  def account_image(account, size)
    if account.image.present?
      attachment_url(account, :image, :fill, size, size)
    elsif account.slack_auth
      size == 34 ? account.slack_auth.slack_team_image_34_url : slack_auth.slack_team_image_132_url
    end
  end
end
