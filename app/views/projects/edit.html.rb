class Views::Projects::Edit < Views::Base
  needs :project

  def content
    content_for(:title) { "Editing: #{project.title.strip}" }
    content_for(:description) { project.decorate.description_text(150) }
    full_row { h3 'Project Settings' }
    div(class: 'row') {
      div(class: 'columns large-2') {
        render partial: 'left_menu_items'
      }
      div(class: 'columns large-10') {
        render partial: 'settings_form', locals: { project: project.decorate }
      }
    }
  end
end
