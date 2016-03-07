class Views::Projects::Index < Views::Projects::Base
  needs :projects, :slack_auth

  def content
    projects_header(slack_auth)

    projects.each do |project|
      project_block(project)
    end
  end
end
