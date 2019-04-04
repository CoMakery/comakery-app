class Views::Shared::ProjectHeader < Views::Projects::Base
  needs :project, :current_account

  def content
    content_for(:title) { project.title.strip }

    div(class: 'project-nav') do
      row do
        column('small-12') do
          h2 do
            text project.title
          end
        end
      end
      row do
        ul(class: 'menu') do
          li do
            path = project.unlisted? ? unlisted_project_path(project.long_id) : project_path(project)
            a(href: path) do
              text 'Overview'
            end
          end

          li_if(project.can_be_access?(current_account), class: ('active' if controller_name == 'contributors').to_s) do
            a(href: project_contributors_path(project.show_id)) do
              text ' Contributors'
            end
          end

          li_if(project.can_be_access?(current_account), class: ('active' if controller_name == 'projects' && params[:action] == 'awards').to_s) do
            a(href: awards_project_path(project.id)) do
              text 'Payments'
            end
          end

          li_if(project.tracker) do
            a(href: project.tracker, target: '_blank', class: 'text-link') do
              i(class: 'fa fa-tasks')
              text ' Project Tasks'
            end
          end

          li_if(project.ethereum_contract_explorer_url) do
            a_text = 'Ξthereum Token'
            a_text = 'Qtum Token' if project.token.coin_type_on_qtum?
            link_to a_text, project.ethereum_contract_explorer_url,
              target: '_blank', class: 'text-link'
          end

          li_if(current_account && project.account == current_account, class: ('active' if controller_name == 'projects' && (params[:action] == 'edit' || params[:action] == 'update'))) do
            a(class: 'edit', href: edit_project_path(project)) do
              i(class: 'fa fa-pencil') {}
              text 'Settings'
            end
          end
        end
      end
    end
  end
end
