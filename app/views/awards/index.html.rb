class Views::Awards::Index < Views::Base
  needs :project, :awards, :current_auth

  def content
    render partial: 'shared/project_header'
    full_row {
      render partial: 'awards/activity'
    }
    pages
    render partial: 'shared/awards',
           locals: { project: project, awards: awards, show_recipient: true }
    pages
  end

  def pages
    full_row {
      div(class: 'callout clearfix') {
        div(class: 'pagination float-right') {
          text paginate project.awards.page(params[:page])
        }
      }
    }
  end
end
