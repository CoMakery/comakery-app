class Views::Shared::Navigation < Views::Base
  def content
    div(class: "show-for-small-only") {
      div(class: "clear-both") {}
      div(class: "row project-search") {
        form_for(:projects, url: projects_path, method: "get") do |f|
          div(class: "small-12 columns") {
            input(type: "search", name: "query", placeholder: "search projects", value: params[:query])
            f.submit("Search", class: "button expand")
          }
        end
      }
      div(class: "row slack-instance collapse") {
        div(class: "small-12 columns") {
          if current_account&.slack_auth
            div(class: "top-bar-text") {
              img(src: current_account.slack_auth.slack_team_image_34_url, class: "project-icon")
              text current_account.slack_auth.slack_team_name
            }
          end
        }
      }
      ul(class: "menu") {
        if current_account
          li {
            link_to 'Account', account_path, class: "first"
          }
          li {
            link_to 'Sign out', session_path, method: :delete
          }
        else
          li {
            link_to 'Sign in', login_path, class: "first"
          }
        end
      }
    }
    div(class: "show-for-medium-only") {
      div(class: "clear-both") {}
      div(class: "row project-search") {
        form_for(:projects, url: projects_path, method: "get") do |f|
          div(class: "small-12 columns") {
            input(type: "search", name: "query", placeholder: "search projects", value: params[:query])
            f.submit("Search", class: "button expand")
          }
        end
      }
      div(class: "row collapse slack-instance") {
        div(class: "small-12 columns") {
          if current_account&.slack_auth
            div(class: "top-bar-text") {
              img(src: current_account.slack_auth.slack_team_image_34_url, class: "project-icon")
              text current_account.slack_auth.slack_team_name
            }
          end
        }
      }
      ul(class: "menu") {
        if current_account
          li {
            link_to 'Account', account_path, class: "first"
          }
          li {
            link_to 'Sign out', session_path, method: :delete
          }
        else
          li {
            link_to 'Sign in', login_path, class: "first"
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
    div(class: "show-for-large") {
      div(class: "top-bar-left") {
        ul(class: "menu") {
          li(class: "has-form") {
            div(class: "row project-search") {
              form_for(:projects, url: projects_path, method: "get") do |f|
                div(class: "small-8 columns") {
                  input(type: "search", name: "query", placeholder: "search projects", value: params[:query])
                }
                div(class: "small-4 columns") {
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
    }
  end
end
