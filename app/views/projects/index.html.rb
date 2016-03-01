class Views::Projects::Index < Views::Projects::Base
  needs :projects

  def content
    row {
      column("small-8") {
        h1 "Projects"
      }
      column("small-4") {
        a("New Project", class: buttonish(:small), href: new_project_path) if policy(Project).new?
      }
    }

    projects.each do |project|
      project_block(project)
    end
  end
end
