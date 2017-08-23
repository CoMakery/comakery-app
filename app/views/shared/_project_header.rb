class Views::Shared::ProjectHeader < Views::Projects::Base
  needs :project

  def content
    content_for(:title) { project.title.strip }
    content_for(:description) { project.description_text(150) }

    div(class: 'project-nav') do
      full_row do
        column('small-12') do
          h2 project.title
        end
      end
      full_row do
        ul(class: 'menu') do
          li do
            a(href: project_path(project)) do
              text 'Overview'
            end
          end

          li_if(policy(project).show_contributions?) do
            a(href: project_contributors_path(project)) do
              text ' Contributors'
            end
          end

          li_if(policy(project).show_contributions?) do
            a(href: project_awards_path(project)) do
              text 'Awards'
            end
          end

          li_if(policy(project).show_revenue_info?) do
            a(href: project_revenues_path(project)) do
              text 'Revenues'
            end
          end

          li_if(policy(project).show_revenue_info?) do
            a(href: project_payments_path(project)) do
              text 'Payments'
            end
          end

          li do
            a(href: project_licenses_path(project)) do
              # i(class: "fa fa-gavel")
              text 'Contribution License'
            end
          end

          li_if(project.slack_team_domain) do
            a(href: "https://#{project.slack_team_domain}.slack.com/messages/#{project.slack_channel}", target: '_blank', class: 'text-link') do
              i(class: 'fa fa-slack')
              text 'Slack Channel'
            end
          end

          li_if(project.tracker) do
            a(href: project.tracker, target: '_blank', class: 'text-link') do
              i(class: 'fa fa-tasks')
              text ' Project Tasks'
            end
          end

          li_if(project.ethereum_contract_explorer_url) do
            link_to 'Ξthereum Smart Contract', project.ethereum_contract_explorer_url,
              target: '_blank', class: 'text-link'
          end

          li_if(policy(project).edit?) do
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
