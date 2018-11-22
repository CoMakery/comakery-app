class Views::Contributors::Index < Views::Projects::Base
  needs :chart_data, :table_data, :revenue_share, :contributors

  def content
    render partial: 'shared/project_header'
    column do
      full_row do
        text react_component 'ContributorsSummaryPieChart', chart_data: chart_data
        render partial: 'shared/table/unpaid_revenue_shares'
        render partial: 'shared/table/unpaid_pool'
      end

      pages

      full_row do
        if contributors.present?
          text react_component 'ContributorsTable', table_data: table_data, revenue_share: revenue_share
        end
      end

      pages
    end
  end

  def pages
    full_row do
      div(class: 'callout clearfix') do
        div(class: 'pagination float-right') do
          text paginate contributors
        end
      end
    end
  end
end
