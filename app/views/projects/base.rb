class Views::Projects::Base < Views::Base
  def projects_header(section_heading)
    row {
      column('small-12 medium-10') {
        h2 section_heading
      }
      column('small-12 medium-2') {
        a('New Project', class: buttonish('float-right'), href: new_project_path) if current_account
      }
    }
  end

  def projects_block(projects, project_contributors)
    row {
      projects.each_slice(3) do |left_project, middle_project, right_project|
        column('small-12 medium-6 large-4') {
          project_block(left_project, project_contributors[left_project])
        }
        column('small-12 medium-6 large-4') {
          project_block(middle_project, project_contributors[middle_project]) if middle_project
        }
        column('small-12 medium-6 large-4') {
          project_block(right_project, project_contributors[right_project]) if right_project
        }
      end
    }
  end

  def project_block(project, contributors)
    row(class: (current_account&.same_team_or_owned_project?(project) ? 'project project-highlighted' : 'project').to_s, id: "project-#{project.to_param}") {
      a(href: project_path(project)) {
        div(class: 'sixteen-nine') {
          div(class: 'content') {
            img(src: project_image_url(project, 132), class: 'image-block')
          }
        }
      }
      div(class: 'info') {
        div(class: 'text-overlay') {
          h5 {
            a(project.title, href: project_path(project), class: 'project-link')
          }
          a(href: project_path(project)) {
            i project.legal_project_owner
          }
        }
        a(href: project_path(project)) {
          img(src: project_image_url(project, 132), class: 'icon')
        }

        p(class: 'description no-last-award') { text project.description_text }

        div(class: 'contributors') {
          owner = project.account

          ([owner].compact + Array.wrap(contributors)).uniq(&:id).each do |contributor|
            tooltip(contributor.name) {
              img(src: account_image_url(contributor, 34), class: 'contributor avatar-img')
            }
          end
        }
      }
    }
  end

  def project_image(project)
    attachment_url(project, :image) || image_tag('default_project_image.png')
  end
end
