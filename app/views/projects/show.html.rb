class Views::Projects::Show < Views::Projects::Base
  needs :project, :award, :awardable_authentications, :awardable_types, :award_data, :can_award, :award_links

  def content
    render partial: 'shared/project_header'

    div(class: 'project-head content') {
      render partial: 'description'
      row {
        render partial: 'shared/award_progress_bar'
      }
    }

    div(class: 'project-body content-box') {
      row {
        column('large-6 medium-12', id: 'awards') {
          render partial: 'award_send'
        }
        column('large-6 medium-12') {
          row(class: 'project-terms') {
            h4 'Project Terms'
            render 'shared/award_form_terms'
          }
        }
      }
      row{
        column('medium-12'){
          h4 'Award Links'
          table(class: 'award-rows') {
            tr(class: 'header-row') {
              th(class: 'small-3') { text 'Type' }
              th(class: 'small-1') { text 'Amount' }
              th(class: 'small-1') { text 'Quantity' }
              th(class: 'small-2') { text 'Date' }
              th(class: 'small-1') { text 'Status' }
              th(class: 'small-4') { text 'Link' }
            }
            award_links.each do |award_link|
              tr(class: 'award-row') {
                td(class: 'small-3 award-type') {
                  text award_link.award_type.name
                }

                td(class: 'small-1 award-unit-amount financial') {
                  text award_link.award_type.amount
                }

                td(class: 'small-1 award-quantity financial') {
                  text award_link.quantity
                }
                td(class: 'small-2') {
                  text raw award_link.created_at.strftime('%b %d, %Y').gsub(' ', '&nbsp;')
                }
                td(class: 'small-1') {
                  text award_link.status
                }
                td(class: 'small-4') {
                  text award_link.link
                }
              }
            end
          }
        }
      }
    }
  end
end
