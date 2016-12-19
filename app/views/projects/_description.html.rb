class Views::Projects::Description < Views::Projects::Base
  needs :project, :can_award
  def content
    div {
      row {
        column("large-6 small-12") {
          if project.video_url
            div(class: "project-video") {
              div(class: "flex-video widescreen") {
                iframe(width: "454", height: "304", src: "//www.youtube.com/embed/#{project.youtube_id}?modestbranding=1&iv_load_policy=3&rel=0&showinfo=0&color=white&autohide=0", frameborder: "0")
              }
            }
          else
            div {
              div(class: "content") {
                img(src: project_image(project), class: "project-image")
              }
            }
          end
          p(class: 'centered') {
            text "Lead by "
            b "#{project.owner_slack_user_name}"
            text " with "
            strong project.slack_team_name
          }
        }
        column("large-6 small-12 header-graphic") {
          div(class: 'content-box') {
            full_row {
              p(class: "description") {
                text raw project.description_html
              }
            }
          }
        }

      }
    }
  end
end