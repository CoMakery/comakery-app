class Views::Projects::Edit < Views::Base
  needs :project

  def content
    content_for(:title) { "Editing: #{project.title.strip}" }
    content_for(:description) { project.decorate.description_text(150) }

    render partial: "form", locals: {project: project}
  end
end
