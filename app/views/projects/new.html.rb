class Views::Projects::New < Views::Base
  needs :project

  def content
    full_row { h1 "Create a Project" }
    render partial: "settings_form", locals: {project: project.decorate}
  end
end

