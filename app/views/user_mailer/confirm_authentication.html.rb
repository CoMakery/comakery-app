class Views::UserMailer::ConfirmEmail < Views::Base
  needs :url
  def content
    row do
      text "Someone tried to login Comakery via #{@authentication.provider} account which has same email like your. Please click "
      link_to 'here', url
      text ' to verify if it was you.'
    end
  end
end
