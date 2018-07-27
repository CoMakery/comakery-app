class Views::Projects::Landing < Views::Projects::Base
  needs :my_projects, :archived_projects, :team_projects, :my_project_contributors, :archived_project_contributors, :team_project_contributors

  def content
    if current_account
      projects_header('')
      if my_projects.any?
        full_row { h1 'mine' }
        projects_block(my_projects, my_project_contributors)
      end
      if team_projects.any?
        full_row { h1 'team' }
        projects_block(team_projects, team_project_contributors)
      end
      if archived_projects.any?
        full_row { h1 'archived' }
        projects_block(archived_projects, archived_project_contributors)
      end
    else
      content_for(:pre_body) do
        div(class: 'intro') do
          div(class: 'show-for-medium') do
            video_tag('collaboration.mp4', autobuffer: true, autoplay: true, loop: true)
          end
          div(class: 'overlay') {}
          div(class: 'overlay2') {}
          div(class: 'intro-content') do
            div(class: 'show-for-small-only') do
              h3 do
                text 'Collaborate on Products'
                br
                text 'Share the Revenue'
              end
            end
            div(class: 'show-for-medium-only') do
              h3 do
                text 'Collaborate on Products'
                br
                text 'Share the Revenue'
              end
            end
            div(class: 'show-for-large') do
              h3 do
                text 'Collaborate on Products'
                br
                text 'Share the Revenue'
              end
            end
            a('Sign in with Slack', class: buttonish << 'margin-small', href: login_path)
            a('Sign in with Discord', class: buttonish << 'margin-small', href: login_discord_path)
            a('Sign in with MetaMask', class: buttonish << 'margin-small signin-with-metamask', href: 'javascript:void(0)')
            a("or join #{t('company_name')}'s Slack", class: 'beta-signup', href: t('company_public_slack_url'))
            render 'sessions/metamask_modal'
          end
        end
        div(class: 'how-it-works') do
          div(class: 'small-10 small-centered columns') do
            row do
              column('small-12 large-4') do
                div(class: 'number') { text '1' }
                h4 'Contribute'
                p 'Join a project or start one. Contribute code, design, content, marketing, or ideas.'
              end
              column('small-12 large-4') do
                div(class: 'number') { text '2' }
                h4 'Earn'
                p 'Earn shares of future revenue. Get recognized for your skills and unlock new opportunities.'
              end
              column('small-12 large-4') do
                div(class: 'number') { text '3' }
                h4 'Share The Upside'
                p 'Get paid your fair share of revenue.'
              end
            end
          end
        end
      end
      full_row { h1 'Featured Projects' }
      projects_block(my_projects, my_project_contributors)
    end

    a('Browse All', href: projects_path, class: 'more')
    content_for :js do
      cookieconsent
    end
  end

  # rubocop:disable Rails/OutputSafety
  def cookieconsent
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        window.cookieconsent.initialise({
          "palette": {
            "popup": {
              "background": "#237afc"
            },
            "button": {
              "background": "#fff",
              "text": "#237afc"
            }
          }
        })
      });
    JAVASCRIPT
  end
end
