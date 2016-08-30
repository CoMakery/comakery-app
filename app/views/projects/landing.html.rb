class Views::Projects::Landing < Views::Projects::Base
  needs :private_projects, :public_projects, :private_project_contributors, :public_project_contributors

  def content
    if current_account&.slack_auth
      projects_header("#{current_account.slack_auth.slack_team_name} projects")
      projects_block(private_projects, private_project_contributors)
    else
      content_for(:pre_body) {
        div(class: "intro") {
          div(class:"show-for-medium") {
            video_tag("collaboration.mp4", autobuffer: true, autoplay: true, loop: true)
          }
          div(class:"overlay") {}
          div(class:"overlay2") {}
          div(class:"intro-content") {
            div(class:"show-for-small-only") {
              h3 {
                text "Collaborate on Products and Share the Revenue"
              }
            }
            div(class:"show-for-medium-only") {
              h3 {
                text "Collaborate on Products"
                br
                text "Share the Revenue"
              }
            }
            div(class:"show-for-large") {
              h3 {
                text "Collaborate on Products"
                br
                text "Share the Revenue"
              }
            }
            a("Sign in with Slack", class: buttonish << "margin-small", href: login_path)
            a("get updates", class: "beta-signup", href: 'http://eepurl.com/b9ISjX')
          }
        }
        div(class: "how-it-works") {
          div(class: "small-10 small-centered columns") {
            row {
              column("small-12 large-4") {
                div(class:"number") { text "1" }
                h4 "Contribute"
                p "Join a project or start one for your Slack team. Contribute code, design, marketing, or ideas."
              }
              column("small-12 large-4") {
                div(class:"number") { text "2" }
                h4 "Receive"
                p "Receive project coin awards and recognition for your contributions."
              }
              column("small-12 large-4") {
                div(class:"number") { text "3" }
                h4 "Share Revenue"
                p "Project coins become cash when your project earns revenue."
              }
            }
          }
        }
      }
    end

    full_row { h1 "Public Projects" }
    projects_block(public_projects, public_project_contributors)

    a("Browse All", href: projects_path, class: "more")
  end
end
