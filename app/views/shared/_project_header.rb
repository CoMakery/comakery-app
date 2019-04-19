class Views::Shared::ProjectHeader < Views::Projects::Base
  needs :project

  def project_page
    return 'contributors' if controller_name == 'contributors'
    return 'awards' if controller_name == 'projects' && params[:action] == 'awards'
  end

  def content
    div class: 'layout--content' do
      div class: 'layout--content--title' do
        text react_component('layouts/ProjectSetupHeader', project_id: project.id,
                                                           project_title: project.title,
                                                           project_page: project_page)
      end
      hr class: 'layout--content--hr'
    end
  end
end
