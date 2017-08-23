class Views::Projects::Landing < Views::Projects::Base
  needs :private_projects, :public_projects, :private_project_contributors, :public_project_contributors

  def content
    if current_account&.slack_auth
      projects_header("#{current_account.slack_auth.slack_team_name} projects")
      projects_block(private_projects, private_project_contributors)
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
            a("or join CoMakery's Slack", class: 'beta-signup', href: 'https://join-comakery-slack.herokuapp.com')
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
    end

    full_row { h1 'Featured Projects' }
    projects_block(public_projects, public_project_contributors)

    a('Browse All', href: projects_path, class: 'more')
  end
end
