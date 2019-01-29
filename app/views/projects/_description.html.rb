class Views::Projects::Description < Views::Projects::Base
  needs :project, :can_award

  def content
    div do
      row do
        column('large-6 small-12', style: 'padding-left: 0') do
          if project.video_url&.match /youtube/
            div(class: 'project-video') do
              div(class: 'flex-video widescreen') do
                iframe(width: '454', height: '304', src: "//www.youtube.com/embed/#{project.video_id}?modestbranding=1&iv_load_policy=3&rel=0&showinfo=0&color=white&autohide=0", frameborder: '0')
              end
            end
          else
            div do
              div(class: 'content') do
                img(src: project_image(project), class: 'project-image')
              end
            end
          end
        end
        column('large-6 small-12 header-graphic') do
          full_row do
            h4 'About'
            div(class: 'project-desc') do
              div(class: 'preview-content') do
                p(class: 'description') do
                  text raw project.description_html
                end
              end
            end
            div(class: 'read-more') do
              link_to 'More..', 'javascript:;', class: 'more-link', data: { open: 'full-description' }
            end
            div(id: 'full-description', class: 'reveal', 'data-reveal': true, style: 'padding-top: 1.5rem;') do
              text raw project.description_html
              button(class: 'close-button', 'data-close': true, 'aria-label': 'Close modal', type: 'button', style: 'top: 0; right: 0.5rem;') do
                span('aria-hidden': 'true') do
                  text '&times;'.html_safe
                end
              end
            end
          end
          full_row do
            ul(class: 'menu simple awarded-info description-stats') do
              li_if(project.revenue_share?) do
                h5 'Reserved For Contributors'
                div(class: 'token-numbers revenue-percentage') do
                  text project.royalty_percentage_pretty.to_s
                  span(class: 'balance-type') { text ' of project revenue' }
                  if project.revenue_sharing_end_date.present?
                    br
                    span(class: 'help-text') do
                      text "Until #{project.revenue_sharing_end_date_pretty}"
                    end
                  end
                end
              end
            end
          end
        end
      end
      row do
        column('large-6 small-12', style: 'color: #9a9a9a') do
          column('large-6 small-12') do
            text 'Team Leaders'
            br
            tooltip(project.account.decorate.name) do
              img(src: account_image_url(project.account, 34), class: 'avatar-img', style: 'margin-top: 2px')
            end
          end

          column('large-6 small-12') do
            text 'Top Contributors'
            br
            project.top_contributors.each do |contributor|
              tooltip(contributor.decorate.name) do
                img(src: account_image_url(contributor, 34), class: 'avatar-img', style: 'margin-top: 2px')
              end
            end
          end
        end

        column('large-6 small-12', style: 'color: #9a9a9a') do
          render partial: 'shared/award_progress_bar'
        end
      end
    end
  end
end
