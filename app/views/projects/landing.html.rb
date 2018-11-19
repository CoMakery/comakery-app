class Views::Projects::Landing < Views::Projects::Base
  needs :my_projects, :archived_projects, :team_projects, :my_project_contributors, :archived_project_contributors, :team_project_contributors

  def content
    projects_header('')
    if my_projects.any?
      full_row { h1 'mine' }
      projects_block(my_projects, my_project_contributors)
    end
    if team_projects.any?
      full_row { h1 'team' }
      projects_block(team_projects, team_project_contributors)
    end
    if archived_projects.any?
      full_row { h1 'archived' }
      projects_block(archived_projects, archived_project_contributors)
    end

    a('Browse All', href: projects_path, class: 'more')
    # content_for :js do
    #   cookieconsent
    # end
  end

  # rubocop:disable Rails/OutputSafety
  def cookieconsent
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        window.cookieconsent.initialise({
          "palette": {
            "popup": {
              "background": "#237afc"
            },
            "button": {
              "background": "#fff",
              "text": "#237afc"
            }
          }
        })
      });
    JAVASCRIPT
  end
end
