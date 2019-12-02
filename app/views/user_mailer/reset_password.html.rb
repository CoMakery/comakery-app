class Views::UserMailer::ResetPassword < Views::Base
  use_instance_variables_for_assigns true

  needs :url
  def content
    row do
      text 'Please click '
      link_to 'here', url
      text ' to set your new password'
    end
  end
end
