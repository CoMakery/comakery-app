module ApplicationHelper
  def account_image_url(account, size)
    attachment_url(account, :image, :fill, size, size, fallback: 'default_account_image.jpg')
  end

  def project_image_url(obj, size)
    attachment_url(obj, :image, :fill, size, size, fallback: 'default_project_image.png')
  end

  def award_status(award)
    award.confirmed? ? image_tag('tickicon.png', size: '16x16') : link_to('confirm', confirm_award_path(award.confirm_token))
  end
end
