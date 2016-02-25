class Views::Projects::Base < Views::Base
  def projects_block(projects)
    projects.each_slice(2) do |left_project, right_project|
      row {
        column("small-6") {
          project_block(left_project)
        }
        column("small-6") {
          project_block(right_project) if right_project
        }
      }
    end
  end

  def project_block(project)
    row(class: "project", id: "project-#{project.to_param}") {
      column("small-4") {
        img(src: attachment_url(project, :image, :fill, 100, 100), class: "small-margin", width: 100, height: 100)
      }
      column("small-8") {
        div(class: "small-margin") {
          p { a(project.title, href: project_path(project)) }
          p project.description.truncate(70)
        }
      }
    }
  end
end
