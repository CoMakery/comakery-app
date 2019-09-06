class Views::Shared::ProjectHeader < Views::Projects::Base
  needs :project, :current_account

  def project_page
    return 'contributors' if controller_name == 'contributors'
    return 'awards' if controller_name == 'projects' && params[:action] == 'awards'
  end

  def content
    div class: 'layout--content' do
      div class: 'layout--content--title' do
        text react_component(
          'layouts/ProjectSetupHeader',
          project_for_header: project.header_props,
          mission_for_header: project&.mission&.decorate&.header_props,
          owner: current_account&.owned_project?(project),
          current: project_page
        )
      end
    end
  end
end
