class Views::Projects::Landing < Views::Projects::Base
  needs :private_projects, :public_projects

  def content
    full_row { h1 "Private Projects" }
    private_projects.each do |project|
      project_block(project)
    end

    full_row { h1 "Public Projects" }
    public_projects.each do |project|
      project_block(project)
    end

    a("Browse All", href: projects_path)
  end
end

