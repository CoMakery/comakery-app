class Views::Shared::ProjectHeader < Views::Projects::Base
  needs :project, :current_account

  def content
    content_for(:title) { project.title.strip }

    div(class: 'project-nav') do
      full_row do
        column('small-12') do
          h2 do
            text project.title
            if project.legal_project_owner.present?
              span(style: 'color: #9A9A9A;') do
                text " by #{project.legal_project_owner}"
              end
            end
          end
        end
      end
      full_row do
        ul(class: 'menu') do
          li(class: ('active' if controller_name == 'projects' && params[:action] != 'edit').to_s) do
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

          li_if(project.can_be_access?(current_account), class: ('active' if controller_name == 'awards').to_s) do
            a(href: project_awards_path(project.show_id)) do
              text 'Awards'
            end
          end

          li_if(project.show_revenue_info?(current_account), class: ('active' if controller_name == 'revenues').to_s) do
            a(href: project_revenues_path(project.show_id)) do
              text 'Revenues'
            end
          end

          li_if(project.show_revenue_info?(current_account), class: ('active' if controller_name == 'payments').to_s) do
            a(href: project_payments_path(project.show_id)) do
              text 'Payments'
            end
          end
          # TODO: link to channel(s)
          # li_if(project.slack_team_domain) {
          #   a(href: "https://#{project.slack_team_domain}.slack.com/messages/#{project.slack_channel}", target: '_blank', class: 'text-link') {
          #     i(class: 'fa fa-slack')
          #     text 'Slack Channel'
          #   }
          # }

          li_if(project.tracker) do
            a(href: project.tracker, target: '_blank', class: 'text-link') do
              i(class: 'fa fa-tasks')
              text ' Project Tasks'
            end
          end

          li_if(project.ethereum_contract_explorer_url) do
            link_to 'Ξthereum Token', project.ethereum_contract_explorer_url,
              target: '_blank', class: 'text-link'
          end

          li_if(current_account && project.account == current_account, class: ('active' if controller_name == 'projects' && params[:action] == 'edit')) do
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
