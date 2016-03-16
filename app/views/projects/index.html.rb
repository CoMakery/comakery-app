class Views::Projects::Index < Views::Projects::Base
  needs :projects

  def content
    projects_header(current_user.slack_auth) if current_user&.slack_auth

    if params[:query]
      if projects.size == 1
        p { text "There was 1 search result for: \"#{params[:query]}\""}
      else
        p { text "There were #{projects.size} search results for: \"#{params[:query]}\""}
      end
    end

    projects_block(projects)

    a("Browse All", href: projects_path)
  end
end
