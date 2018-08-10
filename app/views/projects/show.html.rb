class Views::Projects::Show < Views::Projects::Base
  needs :project, :award, :awardable_types, :can_award

  def content
    render partial: 'shared/project_header'

    div(class: 'project-head content') {
      render partial: 'projects/description'
    }

    div(class: 'project-body content-box') {
      row {
        column('large-6 medium-12', id: 'awards') {
          render partial: 'projects/award_send'
        }
        column('large-6 medium-12') {
          row(class: 'project-terms') {
            h4 'Project Terms'
            render 'shared/award_form_terms'
          }
        }
      }
    }
  end
end
