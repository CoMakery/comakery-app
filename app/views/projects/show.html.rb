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
      a("New Project", href: new_project_path)
    }
  end
end
