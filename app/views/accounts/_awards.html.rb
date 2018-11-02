class Views::Accounts::Awards < Views::Base
  needs :awards, :current_account

  def content
    div(class: 'table-scroll table-box', style: 'margin-right: 0') do
      table(class: 'award-rows', style: 'min-width: 100%') do
        tr(class: 'header-row') do
          th(class: 'small-4') { text 'Project' }
          th(class: 'small-1') { text 'Token' }
          th(class: 'small-2') { text 'Award' }
          th(class: 'small-2') { text 'Date' }
          th(class: 'small-3') { text 'Blockchain Transaction' }
        end
        awards.each do |award|
          project = award.project.decorate
          tr(class: 'award-row') do
            td(class: 'small-3') do
              link_to project.title, project_awards_path(project.show_id, mine: true)
            end
            td(class: 'small-1') do
              text project.token_symbol
            end
            td(class: 'small-2') do
              text award.total_amount_pretty
            end
            td(class: 'small-2') do
              text award.created_at.strftime('%b %d, %Y')
            end
            td(class: 'small-4') do
              if award.ethereum_transaction_explorer_url
                link_to award.ethereum_transaction_address_short, award.ethereum_transaction_explorer_url, target: '_blank'
              else
                text 'pending'
              end
            end
          end
        end
      end
    end
  end
end
