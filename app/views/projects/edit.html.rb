class Views::Projects::Edit < Views::Base
  needs :project

  def content
    render partial: 'shared/project_header'
    column('large-12 no-h-pad') do
      div(class: 'columns large-2') do
        render partial: 'left_menu_items'
      end
      div(class: 'columns large-10') do
        render partial: 'settings_form', locals: { project: project.decorate }
      end
    end
  end
end
