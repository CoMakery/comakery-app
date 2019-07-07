class Views::Projects::Base < Views::Base
  def projects_header(section_heading)
    row do
      column('small-12 medium-10') do
        h2 section_heading
      end
      column('small-12 medium-2') do
        a('New Project', class: buttonish('float-right'), href: new_project_path) if policy(Project).new?
      end
    end
  end

  def projects_block(projects, project_contributors)
    row do
      projects.each_slice(3) do |left_project, middle_project, right_project|
        column('small-12 medium-6 large-4') do
          project_block(left_project, project_contributors[left_project])
        end
        column('small-12 medium-6 large-4') do
          project_block(middle_project, project_contributors[middle_project]) if middle_project
        end
        column('small-12 medium-6 large-4') do
          project_block(right_project, project_contributors[right_project]) if right_project
        end
      end
    end
  end

  def project_block(project, contributors)
    path = project.unlisted? ? unlisted_project_path(project.long_id) : project_path(project)
    row(class: (current_account&.same_team_or_owned_project?(project) ? 'project project-highlighted' : 'project').to_s, id: "project-#{project.to_param}") do
      a(href: path) do
        div(class: 'sixteen-nine') do
          div(class: 'content') do
            img(src: project_image_url(project, 367), class: 'image-block')
          end
        end
      end
      div(class: 'info') do
        div(class: 'text-overlay') do
          h5(class: 'project_block--title') do
            a(project.title, href: path)

            if policy(project).edit?
              a(href: project_award_types_path(project), class: 'project_block--title--edit-link fa fa-cog')
            end
          end
        end

        p(class: 'description no-last-award') { text project.description_text }

        div(class: 'contributors') do
          owner = project.account

          ([owner].compact + Array.wrap(contributors)).uniq(&:id).each do |contributor|
            contributor = contributor.decorate
            tooltip(contributor.name) do
              img(src: account_image_url(contributor, 34), class: 'contributor avatar-img')
            end
          end
        end
      end
    end
  end

  def project_image(project)
    attachment_url(project, :image) || image_tag('default_project_image.png')
  end
end
