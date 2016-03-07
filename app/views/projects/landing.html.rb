class Views::Projects::Landing < Views::Projects::Base
  needs :private_projects, :public_projects, :slack_auth

  def content
    if current_account
      projects_header(slack_auth)
      projects_block(private_projects)
    end

    full_row { h1 "Public Projects" }
    projects_block(public_projects)

    a("Browse All", href: projects_path)
  end
end
