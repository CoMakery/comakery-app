class Views::UserMailer::SendInviteToPlatform < Views::Base
  use_instance_variables_for_assigns true

  needs :url, :project, :project_role, :domain_name
  def content
    row do
      text "You have been invited to have the role '#{project_role.capitalize}' for the project #{project.title} on #{domain_name}."
      text 'To accept the invitation follow this '
      link_to 'link', url
    end
  end
end
