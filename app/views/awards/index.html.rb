class Views::Awards::Index < Views::Base
  needs :project, :awards, :current_auth

  def content
    render partial: 'shared/project_header'
    full_row do
      render partial: 'awards/activity'
    end
    pages
    render partial: 'shared/awards',
           locals: { project: project, awards: awards, show_recipient: true }
    pages
  end

  def pages
    full_row do
      div(class: 'callout clearfix') do
        div(class: 'pagination float-right') do
          text paginate project.awards.page(params[:page])
        end
      end
    end
  end
end
