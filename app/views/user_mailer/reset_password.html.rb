class Views::UserMailer::ResetPassword < Views::Base
  needs :url
  def content
    row do
      text 'Please click '
      link_to 'here', url
      text ' to set your new password'
    end
  end
end
