class Views::Projects::Description < Views::Projects::Base
  needs :project, :can_award, :award_data, :current_auth

  def content
    div do
      row do
        column('large-6 small-12') do
          if project.video_url
            div(class: 'project-video') do
              div(class: 'flex-video widescreen') do
                iframe(width: '454', height: '304', src: "//www.youtube.com/embed/#{project.youtube_id}?modestbranding=1&iv_load_policy=3&rel=0&showinfo=0&color=white&autohide=0", frameborder: '0')
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
            p do
              text 'Lead by '
              b project.owner_slack_user_name.to_s
              text ' with '
              strong project.slack_team_name
            end
            p(class: 'description') do
              text raw project.description_html
            end
            if project.project_token?
              p do
                i 'This project does not offer royalties or a share of revenue. It does award project tokens. Read the Project Terms for more details.'
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

              if award_data[:contributions_summary].present?
                li(class: 'top-contributors') do
                  h5 'Top Contributors'
                  award_data[:contributions_summary].first(5).each do |contributor|
                    tooltip(contributor[:name]) do
                      img(src: contributor[:avatar], class: 'avatar-img')
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def total_tokens_issued_pretty
    number_with_precision(award_data[:award_amounts][:total_tokens_issued], precision: 0, delimiter: ',')
  end

  def my_project_tokens
    award_data[:award_amounts][:my_project_tokens]
  end

  def total_tokens_issued
    award_data[:award_amounts][:total_tokens_issued]
  end
end
