class Views::Projects::Show < Views::Base
  needs :project

  def content
    full_row {
      h1 project.title
    }
    full_row {
      text project.description
    }
    full_row {
      a "Project Tasks »", class: buttonish, href: project.tracker
    }
    full_row {
      a("Edit", class: buttonish, href: edit_project_path(project))
      a("Back", class: buttonish, href: projects_path)
    }
  end
end
