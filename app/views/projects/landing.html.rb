class Views::Projects::Landing < Views::Projects::Base
  needs :private_projects, :public_projects

  def content
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
          a("Get Started", class: buttonish << "margin-small", href: projects_path)
        }
      }
    }

    if current_account&.slack_auth
      projects_header(current_account.slack_auth)
      projects_block(private_projects)
    end

    full_row { h1 "Public Projects" }
    projects_block(public_projects)

    a("Browse All", href: projects_path)
  end
end
