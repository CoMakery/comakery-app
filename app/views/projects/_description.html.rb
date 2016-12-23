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
            if project.project_coin?
              p {
                i 'This project does not offer royalties or a share of revenue. It does award project coins. Read the Project Terms for more details.'
              }
            end
          }
          full_row {

            ul(class: 'menu simple awarded-info description-stats') {
              li_if(project.revenue_share?) {
                h5 "Revenue Shared"
                span(class: "coin-numbers revenue-percentage") {
                  text project.royalty_percentage_pretty
                }
              }

              if award_data[:award_amounts][:my_project_coins].present?
                li(class: 'my-share') {
                  h5 "My #{project.payment_description}"
                  span(class: " coin-numbers") {
                    text number_with_precision(award_data[:award_amounts][:my_project_coins], precision: 0, delimiter: ',')
                  }
                  span(class: "balance-type") { text " of #{total_coins_issued}" }
                }

                li_if(project.revenue_share?, class: 'my-balance') {
                  h5 "My Balance"
                  span(class: "coin-numbers") {
                    text project.my_balance_pretty
                    span(class: "balance-type") { text " of #{project.balance_pretty}" }
                  }
                }
              end

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
          }
        }

      }
    }
  end


  def total_coins_issued_pretty
    number_with_precision(award_data[:award_amounts][:total_coins_issued], precision: 0, delimiter: ',')
  end

  def my_project_coins
    award_data[:award_amounts][:my_project_coins]
  end

  def total_coins_issued
    award_data[:award_amounts][:total_coins_issued]
  end
end