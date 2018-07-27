class Views::Layouts::Navigation < Views::Base
  def content
    ul(class: 'menu show-for-medium') do
      li(class: 'slack-instance') do
        if current_account
          div(class: 'top-bar-text') do
            img(src: account_image_url(current_account, 34), class: 'avatar')
            text current_account.decorate.name
          end
        end
      end
      if current_account
        li do
          link_to 'ACCOUNT', account_path
        end
        li do
          link_to 'SIGN OUT', session_path, method: :delete
        end
      else
        li do
          link_to 'CONTACT US', 'mailto:support@comakery.com'
        end
        li do
          link_to 'SIGN IN', new_session_path
        end
        li do
          link_to 'SIGN UP', new_account_path, class: 'pink-text'
        end
      end
    end

    ul(class: 'menu hide-for-medium', style: 'font-size: 14px;') do
      li(class: 'slack-instance') do
        if current_account
          div(class: 'top-bar-text') do
            text current_account.decorate.name
          end
        end
      end
      if current_account
        li do
          link_to 'ACCOUNT', account_path
        end
        li do
          link_to 'SIGN OUT', session_path, method: :delete
        end
      else
        li do
          link_to 'CONTACT US', 'mailto:support@comakery.com'
        end
        li do
          link_to 'SIGN IN', new_session_path
        end
        li do
          link_to 'SIGN UP', new_account_path, class: 'pink-text'
        end
      end
    end
  end
end
