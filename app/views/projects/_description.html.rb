class Views::Projects::Description < Views::Projects::Base
  needs :project, :can_award, :award_data

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
        }
        column("large-6 small-12 header-graphic") {
          full_row {
            h4 "About"
            p {
              text "Lead by "
              b "#{project.owner_slack_user_name}"
              text " with "
              strong project.slack_team_name
            }
            p(class: "description") {
              text raw project.description_html
            }
          }
          full_row {

            awarded_info
          }

        }

      }
    }
  end


  def awarded_info
    ul(class: 'menu simple awarded-info description-stats') {
      if award_data[:award_amounts][:my_project_coins]
        li {
          h5 "My Balance"
          span(class: "coin-numbers") {
            text project.currency_denomination
            text number_with_precision(award_data[:award_amounts][:my_project_coins], precision: 0, delimiter: ',')
          }
          span(class: "balance-type") { text project.payment_description }
        }
      end

      li {
        h5 "Project Balance"
        span(class: " coin-numbers") {
          text project.currency_denomination
          text number_with_precision(total_coins_issued, precision: 0, delimiter: ',')

        }
        span(class: "balance-type") { text project.payment_description }
      }

      if award_data[:contributions_summary].present?
        li(class: 'top-contributors') {
            h5 "Top Contributors"
            award_data[:contributions_summary].first(5).each do |contributor|
              tooltip(contributor[:name]) {
                img(src: contributor[:avatar], class: "avatar-img")
              }
            end
          }
      end
    }
  end

  def total_coins_issued
    award_data[:award_amounts][:total_coins_issued]
  end

  def percentage_issued
    total_coins_issued * 100 / project.maximum_coins.to_f
  end
end