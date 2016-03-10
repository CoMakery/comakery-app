class Views::Shared::Navigation < Views::Base
  def content
    section(class: "top-bar-section") {
      ul(class: "right") {
        li(class: "slack-instance") {
          if current_account&.slack_auth
            div(class: "top-bar-text") {
              img(src: current_account.slack_auth.slack_team_image_34_url, class: "project-icon")
              text current_account.slack_auth.slack_team_name
            }
          end
        }
        if current_account
          li {
            link_to 'Sign out', session_path, method: :delete
          }
        else
          li {
            link_to 'Sign in', slack_auth_path
          }
        end
      }
    }
  end
end
