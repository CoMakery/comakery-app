class Views::Projects::Index < Views::Projects::Base
  needs :projects, :slack_auth

  def content
    projects_header(slack_auth)

    if params[:query]
      if projects.size == 1
        p { text "There was 1 search result for: \"#{params[:query]}\""}
      else
        p { text "There were #{projects.size} search results for: \"#{params[:query]}\""}
      end
    end

    projects.each do |project|
      project_block(project)
    end
  end
end
