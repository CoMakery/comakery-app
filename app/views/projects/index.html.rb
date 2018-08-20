class Views::Projects::Index < Views::Projects::Base
  needs :projects, :project_contributors

  def content
    projects_header('Projects')

    projects_block(projects, project_contributors)

    a('Browse All', href: projects_path) if params[:query]
  end
end
