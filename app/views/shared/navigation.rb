class Views::Shared::Navigation < Views::Base
  def content
    div(class: 'show-for-small-only') do
      div(class: 'clear-both') {}
      div(class: 'row project-search') do
        form_for(:projects, url: projects_path, method: 'get') do |f|
          div(class: 'small-12 columns') do
            input(type: 'search', name: 'query', placeholder: 'search projects', value: params[:query])
            f.submit('Search', class: 'button expand')
          end
        end
      end
      div(class: 'row slack-instance collapse') do
        div(class: 'small-12 columns') do
          if current_account&.slack_auth
            div(class: 'top-bar-text') do
              img(src: current_account.slack_auth.slack_team_image_34_url, class: 'project-icon')
              text current_account.slack_auth.slack_team_name
            end
          end
        end
      end
      ul(class: 'menu') do
        blog_link
        account_links
      end
    end
    div(class: 'show-for-medium-only') do
      div(class: 'clear-both') {}
      div(class: 'row project-search') do
        form_for(:projects, url: projects_path, method: 'get') do |f|
          div(class: 'small-12 columns') do
            input(type: 'search', name: 'query', placeholder: 'search projects', value: params[:query])
            f.submit('Search', class: 'button expand')
          end
        end
      end
      div(class: 'row collapse slack-instance') do
        div(class: 'small-12 columns') do
          if current_account&.slack_auth
            div(class: 'top-bar-text') do
              img(src: current_account.slack_auth.slack_team_image_34_url, class: 'project-icon')
              text current_account.slack_auth.slack_team_name
            end
          end
        end
      end
      ul(class: 'menu') do
        blog_link
        social_media_links
        account_links
      end
    end
    div(class: 'show-for-large') do
      div(class: 'top-bar-left') do
        ul(class: 'menu') do
          li(class: 'has-form') do
            div(class: 'row project-search') do
              form_for(:projects, url: projects_path, method: 'get') do |f|
                div(class: 'small-8 columns') do
                  input(type: 'search', name: 'query', placeholder: 'search projects', value: params[:query])
                end
                div(class: 'small-4 columns') do
                  f.submit('Search', class: 'button expand')
                end
              end
            end
          end

          blog_link
          social_media_links

          li(class: 'slack-instance') do
            if current_account&.slack_auth
              div(class: 'top-bar-text') do
                img(src: current_account.slack_auth.slack_team_image_34_url, class: 'project-icon')
                text current_account.slack_auth.slack_team_name
              end
            end
          end
          if current_account
            li do
              link_to 'Account', account_path
            end
            li do
              link_to 'Sign out', session_path, method: :delete
            end
          else
            li do
              link_to 'Sign in', login_path
            end
          end
        end
      end
    end
  end

  def blog_link
    li do
      link_to 'Media', 'https://media.comakery.com'
    end
  end

  def social_media_links
    li do
      a(href: '//github.com/CoMakery') { i(class: 'fa fa-github') }
    end
    li do
      a(href: '//twitter.com/comakery') { i(class: 'fa fa-twitter') }
    end
  end

  def account_links
    if current_account
      li do
        link_to 'Account', account_path, class: 'first'
      end
      li do
        link_to 'Sign out', session_path, method: :delete
      end
    else
      li do
        link_to 'Sign in', login_path, class: 'first'
      end
    end
  end
end
