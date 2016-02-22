class Views::LoggedOut::Show < Views::Base
  def content
    a(href: "/auth/slack") do
      text "Log in"
    end
  end
end
