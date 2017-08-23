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
    row(class: "project#{project.slack_team_id == current_account&.slack_auth&.slack_team_id ? ' project-highlighted' : ''}", id: "project-#{project.to_param}") do
      a(href: project_path(project)) do
        div(class: 'sixteen-nine') do
          div(class: 'content') do
            img(src: project_image(project), class: 'image-block')
          end
        end
      end
      div(class: 'info') do
        div(class: 'text-overlay') do
          h5 do
            a(project.title, href: project_path(project), class: 'project-link')
          end
          a(href: project_path(project)) do
            i project.slack_team_name
          end
        end
        a(href: project_path(project)) do
          img(src: project.slack_team_image_132_url, class: 'icon')
        end

        p(class: 'description no-last-award') { text project.description_text }

        div(class: 'contributors') do
          # this can go away when project owners become auths instead of accounts
          owner_auth = project.owner_account.authentications.find_by(slack_team_id: project.slack_team_id)

          ([owner_auth].compact + Array.wrap(contributors)).uniq(&:id).each do |contributor|
            tooltip(contributor.display_name) do
              img(src: contributor.slack_icon, class: 'contributor avatar-img')
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
