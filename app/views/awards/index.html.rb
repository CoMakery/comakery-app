class Views::Awards::Index < Views::Base
  needs :project, :awards

  def content
    render partial: 'shared/project_header'
    full_row {
      render partial: 'awards/activity'
    }
    pages
    if current_account
      full_row {
        div(class: 'small-1', style: 'float: left') {
          label {
            checked = params[:mine] == 'true' ? false : true
            radio_button_tag 'mine', url_for, checked
            text 'all'
          }
        }
        div(class: 'small-1', style: 'float: left') {
          label {
            checked = params[:mine] == 'true' ? true : false
            radio_button_tag 'mine', url_for(mine: true), checked
            text 'mine'
          }
        }
      }
    end
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
