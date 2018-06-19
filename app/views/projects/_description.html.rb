class Views::Projects::Description < Views::Projects::Base
  needs :project, :can_award

  def content
    div {
      row {
        column('large-6 small-12') {
          if project.video_url
            div(class: 'project-video') {
              div(class: 'flex-video widescreen') {
                iframe(width: '454', height: '304', src: "//www.youtube.com/embed/#{project.youtube_id}?modestbranding=1&iv_load_policy=3&rel=0&showinfo=0&color=white&autohide=0", frameborder: '0')
              }
            }
          else
            div {
              div(class: 'content') {
                img(src: project_image(project), class: 'project-image')
              }
            }
          end
        }
        column('large-6 small-12 header-graphic') {
          full_row {
            h4 'About'
            div(class: 'project-desc') {
              div(class: 'preview-content') {
                p(class: 'description') {
                  text raw project.description_html
                }
                if project.project_token?
                  p {
                    i 'This project does not offer royalties or a share of revenue. It does award project tokens. Read the Project Terms for more details.'
                  }
                end
              }
            }
            div(class: 'read-more') {
              link_to 'More..', 'javascript:;', class: 'more-link', data: { open: 'full-description' }
            }
            div(id: 'full-description', class: 'reveal', 'data-reveal': true) {
              text raw project.description_html
              button(class: 'close-button', 'data-close': true, 'aria-label': 'Close modal', type: 'button') {
                span('aria-hidden': 'true') {
                  text '&times;'.html_safe
                }
              }
            }
          }
          full_row {
            ul(class: 'menu simple awarded-info description-stats') {
              li_if(project.revenue_share?) {
                h5 'Reserved For Contributors'
                div(class: 'token-numbers revenue-percentage') {
                  text project.royalty_percentage_pretty.to_s
                  span(class: 'balance-type') { text ' of project revenue' }
                  if project.revenue_sharing_end_date.present?
                    br
                    span(class: 'help-text') {
                      text "Until #{project.revenue_sharing_end_date_pretty}"
                    }
                  end
                }
              }
            }
          }
        }
      }
      row {
        column('large-6 small-12', style: 'color: #9a9a9a') {
          column('large-6 small-12') {
            text 'Team Leaders'
            br
            tooltip(project.account.decorate.name) {
              img(src: account_image_url(project.account, 34), class: 'avatar-img', style: 'margin-top: 2px')
            }
          }

          column('large-6 small-12') {
            text 'Top Contributors'
            br
            project.top_contributors.each do |contributor|
              tooltip(contributor.decorate.name) {
                img(src: account_image_url(contributor, 34), class: 'avatar-img', style: 'margin-top: 2px')
              }
            end
          }
        }

        column('large-6 small-12', style: 'color: #9a9a9a') {
          render partial: 'shared/award_progress_bar'
        }
      }
    }
  end
end
