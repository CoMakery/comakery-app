class Views::Projects::Landing < Views::Projects::Base
  needs :private_projects, :public_projects

  def content
    if current_account&.slack_auth
      projects_header("#{current_account.slack_auth.slack_team_name} projects")
      projects_block(private_projects)
    else
      content_for(:pre_body) {
        div(class: "intro") {
          video_tag("collaboration.mp4", autobuffer: true, autoplay: true, loop: true)
          div(class:"overlay") {}
          div(class:"overlay2") {}
          div(class:"intro-content") {
            h3 {
              text "equity at the speed"
              br
              text "of innovation"
            }
            a("Sign in with Slack", class: buttonish << "margin-small", href: login_path)
          }
        }
        div(class: "how-it-works") {
          div(class: "large-10 large-centered columns") {
            row {
              column("small-4") {
                div(class:"number") { text "1" }
                h4 "Contribute"
                p "Contribute code, design, content, or vision, Find a project or start one for your Slack channel."
              }
              column("small-4") {
                div(class:"number") { text "2" }
                h4 "Earn"
                p "Earn project coins, get recognized for your contributions, see feedback, and more."
              }
              column("small-4") {
                div(class:"number") { text "3" }
                h4 "Share"
                p "Share in the value the project creates. Project coins can be tied to revenue or company shares."
              }
            }
          }
        }
      }
    end

    full_row { h1 "Public Projects" }
    projects_block(public_projects)

    a("Browse All", href: projects_path)
  end
end
