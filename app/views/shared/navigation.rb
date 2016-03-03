class Views::Shared::Navigation < Views::Base
  def content
    section(class: "top-bar-section") {
      ul(class: "right") {
        li {
          if current_account
            li {
              link_to 'Log out', session_path, method: :delete
            }
          else
            li {
              link_to 'Log in', slack_auth_path
            }
          end
        }
      }
    }
  end
end
