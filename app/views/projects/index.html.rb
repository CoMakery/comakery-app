class Views::Projects::Index < Views::Projects::Base
  needs :projects, :project_contributors

  def content
    projects_header("Projects")

    if params[:query]
      if projects.size == 1
        p { text "There was 1 search result for: \"#{params[:query]}\""}
      else
        p { text "There were #{projects.size} search results for: \"#{params[:query]}\""}
      end
    end

    projects_block(projects, project_contributors)

    a("Browse All", href: projects_path)
  end
end
