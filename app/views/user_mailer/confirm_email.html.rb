class Views::UserMailer::ConfirmEmail < Views::Base
  needs :url
  def content
    row {
      p {
        text 'Click this '
        link_to 'link', url
        text ' to verify your email address with CoMakery, and we’ll take care of the rest.'
      }
      p {
        text 'From the team at CoMakery, thank you for joining our community. We’re delighted to have you!'
      }
    }
  end
end
