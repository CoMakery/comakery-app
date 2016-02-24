class Views::Projects::Index < Views::Projects::Base
  needs :projects

  def content
    full_row { h1 "Projects" }

    projects.each do |project|
      project_block(project)
    end

    full_row {
      a("New Project", class: buttonish(:small), href: new_project_path)
    }
  end
end
