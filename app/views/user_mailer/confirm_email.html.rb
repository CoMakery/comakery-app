class Views::UserMailer::ConfirmEmail < Views::Base
  needs :url
  def content
    row{
      text "Please click "
      link_to "here", url
      text " to verify you email address"
    }
  end
end
