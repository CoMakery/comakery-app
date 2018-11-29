class Views::Layouts::Navigation < Views::Base
  def content
    ul(class: 'menu show-for-medium') do
      nav_links
    end

    ul(class: 'menu hide-for-medium', style: 'font-size: 14px;') do
      nav_links
    end
  end

  def nav_links
    if current_account
      li do
        div(class: 'top-bar-text') do
          link_to(account_path) do
            img(src: account_image_url(current_account, 34), class: 'avatar')
          end
          link_to current_account.decorate.name, account_path
        end
      end
      if current_account.comakery_admin?
        li do
          link_to 'MISSIONS', root_path
        end
      end
      li do
        link_to 'MY PROJECTS', my_project_path
      end
      li(style: 'padding-right: 0') do
        link_to 'SIGN OUT', session_path, method: :delete
      end
    else
      li do
        link_to 'CONTACT US', 'mailto:support@comakery.com'
      end
      li do
        link_to 'SIGN IN', new_session_path
      end
      li(style: 'padding-right: 0') do
        link_to 'SIGN UP', new_account_path, class: 'pink-text'
      end
    end
  end
end
