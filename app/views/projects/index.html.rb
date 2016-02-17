class Views::Projects::Index < Views::Base
  needs :projects

  def content
    full_row { h1 "Projects" }

    projects.each do |project|
      row(id: "project-#{project.to_param}") {
        column("small-8") {
          text project.title
        }
        column("small-4") {
          a("View", class: buttonish(:small), href: project_path(project))
        }
      }
    end

    full_row {
      a("New Project", class: buttonish(:small), href: new_project_path)
    }
  end
end
