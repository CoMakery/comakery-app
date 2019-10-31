class Views::Projects::Index < Views::Projects::Base
  needs :projects, :project_contributors, :q

  def content
    projects_header(params[:q] ? "Project Search: #{params[:q][:title_or_description_or_token_name_or_mission_name_cont]}" : 'Projects')

    projects_block(projects.decorate, project_contributors)
    text paginate(projects)

    a('Browse All', href: projects_path) if params[:query]
  end
end
