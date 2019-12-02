class Views::UserMailer::ConfirmAuthentication < Views::Base
  use_instance_variables_for_assigns true

  needs :url, :provider
  def content
    row do
      text "Someone tried to login via #{provider} account which has same email like your. Please click "
      link_to 'here', url
      text ' to verify if it was you.'
    end
  end
end
