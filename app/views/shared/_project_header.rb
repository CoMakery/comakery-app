class Views::Shared::ProjectHeader < Views::Projects::Base
  needs :project, :current_account

  def content
    content_for(:title) { project.title.strip }
    content_for(:description) { project.description_text(150) }

    div(class: 'project-nav') {
      full_row {
        column('small-12') {
          h2 project.title
        }
      }
      full_row {
        ul(class: 'menu') {
          li {
            a(href: project_path(project)) {
              text 'Overview'
            }
          }

          li_if(project.can_be_access?(current_account)) {
            a(href: project_contributors_path(project)) {
              text ' Contributors'
            }
          }

          li_if(project.can_be_access?(current_account)) {
            a(href: project_awards_path(project)) {
              text 'Awards'
            }
          }

          li_if(project.show_revenue_info?(current_account)) {
            a(href: project_revenues_path(project)) {
              text 'Revenues'
            }
          }

          li_if(project.show_revenue_info?(current_account)) {
            a(href: project_payments_path(project)) {
              text 'Payments'
            }
          }
          # TODO: link to channel(s)
          # li_if(project.slack_team_domain) {
          #   a(href: "https://#{project.slack_team_domain}.slack.com/messages/#{project.slack_channel}", target: '_blank', class: 'text-link') {
          #     i(class: 'fa fa-slack')
          #     text 'Slack Channel'
          #   }
          # }

          li_if(project.tracker) {
            a(href: project.tracker, target: '_blank', class: 'text-link') {
              i(class: 'fa fa-tasks')
              text ' Project Tasks'
            }
          }

          li_if(project.ethereum_contract_explorer_url) {
            link_to 'Ξthereum Smart Contract', project.ethereum_contract_explorer_url,
              target: '_blank', class: 'text-link'
          }

          li_if(current_account && project.account == current_account) {
            a(class: 'edit', href: edit_project_path(project)) {
              i(class: 'fa fa-pencil') {}
              text 'Settings'
            }
          }
        }
      }
    }
  end
end
