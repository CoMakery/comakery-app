class Views::Projects::Landing < Views::Projects::Base
  needs :private_projects, :public_projects, :slack_team_name, :slack_team_image_34_url

  def content
    if current_account
      full_row {
        column("small-1") { img src: slack_team_image_34_url }
        column("small-11") { h1 "#{slack_team_name} Projects" }
      }
      projects_block(private_projects)
    end

    full_row { h1 "Public Projects" }
    projects_block(public_projects)

    a("Browse All", href: projects_path)
  end
end
