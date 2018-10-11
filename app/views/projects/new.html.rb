class Views::Projects::New < Views::Base
  needs :project

  def content
    full_row { h1 'Create a Project' }
    div(class: 'no-switcher') do
      render partial: 'settings_form', locals: { project: project.decorate, current_section: nil }
    end
  end
end
