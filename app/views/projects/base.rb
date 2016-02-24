class Views::Projects::Base < Views::Base
  def project_block(project)
    row(class: "project", id: "project-#{project.to_param}") {
      column("small-8") {
        text project.title
      }
      column("small-4") {
        a("View", class: buttonish(:small), href: project_path(project))
      }
    }
  end
end
