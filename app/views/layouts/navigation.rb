class Views::Layouts::Navigation < Views::Base
  def content
    ul(class: 'menu show-for-medium') {
      li(class: 'slack-instance') {
        if current_account
          div(class: 'top-bar-text') {
            img(src: account_image_url(current_account, 34), class: 'avatar')
            text current_account.decorate.name
          }
        end
      }
      if current_account
        li {
          link_to 'ACCOUNT', account_path
        }
        li {
          link_to 'SIGN OUT', session_path, method: :delete
        }
      else
        li {
          link_to 'ABOUT US', 'javascript:;'
        }
        li {
          link_to 'SIGN IN', new_session_path
        }
        li {
          link_to 'SIGN UP', new_account_path, class: 'pink-text'
        }
      end
    }

    ul(class: 'menu hide-for-medium', style: 'font-size: 14px;') {
      li(class: 'slack-instance') {
        if current_account
          div(class: 'top-bar-text') {
            text current_account.decorate.name
          }
        end
      }
      if current_account
        li {
          link_to 'ACCOUNT', account_path
        }
        li {
          link_to 'SIGN OUT', session_path, method: :delete
        }
      else
        li {
          link_to 'ABOUT US', 'javascript:;'
        }
        li {
          link_to 'SIGN IN', new_session_path
        }
        li {
          link_to 'SIGN UP', new_account_path, class: 'pink-text'
        }
      end
    }
  end
end
