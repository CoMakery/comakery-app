class Views::UserMailer::SendAwardNotifications < Views::Base
  needs :message
  def content
    row {
      text message
    }
  end
end
