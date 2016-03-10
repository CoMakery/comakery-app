class Views::Shared::Navigation < Views::Base
  def content
    content_for :js do
      text(<<-JAVASCRIPT.html_safe)
        $(function() {
          $(".project-search a").on("click", function() {
            window.location = "http://www.google.com"
          })
        });
      JAVASCRIPT
    end

    section(class: "top-bar-section") {
      ul(class: "right") {
        li(class: "has-form") {
          div(class: "row collapse project-search") {
            form_tag("https://www.google.com", method: "GET") {
              div(class: "large-8 small-9 columns collapse") {
                input(name: "q", type: "text", placeholder: "Search Projects")
              }
              div(class: "large-4 small-3 columns collapse") {
                button_tag("Search", class: "button expand")
              }
            }
          }
        }
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
