module ApplicationHelper
  def account_image_url(account, size)
    attachment_url(account, :image, :fill, size, size, fallback: 'default_account_image.jpg')
  end

  def project_image_url(obj, size)
    attachment_url(obj, :square_image, :fill, size, size, fallback: 'defaul_project.jpg')
  end

  def project_page
    return 'contributors' if controller_name == 'contributors'
    return 'transfers' if controller_name == 'transfers'
    return 'accounts' if controller_name == 'accounts'
    return 'admins' if params[:action] == 'admins'
  end
end
