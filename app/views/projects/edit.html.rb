class Views::Projects::Edit < Views::Base
  needs :project

  def content
    full_row { h1 "Edit Project #{project.title}" }
    render partial: "form", locals: {project: project}
  end
end
