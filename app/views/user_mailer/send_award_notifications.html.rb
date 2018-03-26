class Views::UserMailer::SendAwardNotifications < Views::Base
  needs :url
  def content
    row {
      text 'Please click '
      link_to 'here', url
      text ' to receive your award'
    }
  end
end
