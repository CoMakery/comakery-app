class Views::Projects::ProjectsBlock < Views::Projects::Base
  needs :project, :project_contributors

  def content
    column('small-12 medium-6 large-4') do
      project_block(project, project_contributors[project])
    end
  end
end
