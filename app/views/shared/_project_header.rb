class Views::Shared::ProjectHeader < Views::Projects::Base
  needs :project, :current_account

  def content
    div class: 'layout--content' do
      div class: 'layout--content--title' do
        text react_component(
          'layouts/ProjectSetupHeader',
          project_for_header: project.header_props.merge(project.policy_props(current_account)),
          mission_for_header: project&.mission&.decorate&.header_props,
          current: project_page
        )
      end
    end
  end
end
