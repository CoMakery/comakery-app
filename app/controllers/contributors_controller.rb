class ContributorsController < ApplicationController
  before_action :assign_project
  skip_before_action :require_login, only: :index

  def index
    authorize @project, :show_contributions?

    @contributors  = @project.contributors_by_award_amount.page(params[:page])
    @award_data    = GetContributorData.call(project: @project).award_data
    @revenue_share = @project.revenue_share?

    @chart_data = @award_data[:contributions_summary_pie_chart].map do |award|
      {
        label: award[:name],
        value: award[:net_amount]
      }
    end

    @table_data = @contributors.decorate.map do |contributor|
      {
        image_url: helpers.account_image_url(contributor, 27),
        name: contributor.name,
        awards: contributor.award_by_project(@project).map do |award|
          {
            name: award[:name],
            total: @project.format_with_decimal_places(award[:total])
          }
        end,
        total: @project.format_with_decimal_places(contributor.total),
        remaining: @revenue_share ? contributor.total_awards_remaining_pretty(@project) : nil,
        unpaid: @revenue_share ? contributor.total_revenue_unpaid_remaining_pretty(@project) : nil,
        paid: @revenue_share ? contributor.total_revenue_paid_pretty(@project) : nil
      }
    end
  end
end
