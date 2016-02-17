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
      text project.repo
    }
    full_row {
      a("Back", class: buttonish(:small), href: projects_path)
    }
  end
end
