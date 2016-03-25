class Views::Shared::Navigation < Views::Base
  def content
    div(class: "top-bar-right") {
      ul(class: "menu") {
        li(class: "has-form") {
          div(class: "row collapse project-search") {
            form_for(:projects, url: projects_path, method: "get") do |f|
              div(class: "large-12 small-12 columns collapse") {
                input(type: "search", name: "query", placeholder: "search projects", value: params[:query])
                f.submit("Search", class: "button expand")
              }
            end
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
            link_to 'Sign in', login_path
          }
        end
      }
    }

  end
end
