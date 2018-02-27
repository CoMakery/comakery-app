class Views::UserMailer::ResetPassword < Views::Base
  needs :url
  def content
    row {
      text 'Please click '
      link_to 'here', url
      text ' to set your new password'
    }
  end
end
