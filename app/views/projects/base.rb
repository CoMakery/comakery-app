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
      render partial: 'projects_block', collection: projects, as: :project, cached: true, locals: { project_contributors: project_contributors }
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

            a(href: edit_project_path(project), class: 'project_block--title--edit-link fa fa-cog') if policy(project).edit?
          end
        end

        # rubocop:todo Rails/Output
        p(class: 'description no-last-award') { text project.description_text_truncated(60) }
        # rubocop:enable Rails/Output

        div(class: 'details') do
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
  end

  def project_image(project)
    GetImagePath.call(
      attachment: project.image,
      fallback: image_url('default_project_image.png')
    ).path
  end
end
