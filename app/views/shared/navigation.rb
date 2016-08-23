class Views::Shared::Navigation < Views::Base
  def content
    div(class: "top-bar-right") {
      ul(class: "menu") {
        li(class: "has-form") {
          div(class: "row collapse project-search") {
            form_for(:projects, url: projects_path, method: "get") do |f|
              div(class: "small-8 columns collapse") {
                input(type: "search", name: "query", placeholder: "search projects", value: params[:query])
              }
              div(class: "small-4 columns collapse") {
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
            link_to 'Account', account_path
          }
          li {
            link_to 'Sign out', session_path, method: :delete
          }
        else
          li {
            link_to 'Sign in', login_path
          }
        end
        li {
          a(href: '//github.com/CoMakery') { i(class: "fa fa-github") }
        }
        li {
          a(href: '//twitter.com/comakery') { i(class: "fa fa-twitter") }
        }
      }
    }

  end
end
