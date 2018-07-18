class Views::Projects::Edit < Views::Base
  needs :project

  def content
    render partial: 'shared/project_header'
    column('large-12 no-h-pad') {
      div(class: 'columns large-2') {
        render partial: 'left_menu_items'
      }
      div(class: 'columns large-10') {
        render partial: 'settings_form', locals: { project: project.decorate }
      }
    }
  end
end
