class GetAwardData
  include Interactor

  def call
    project = context.project
    current_account = context.current_account

    awards = project.awards.includes(:account, :award_type).to_a

    context.award_data = {
        pie_chart: pie_chart_data(awards),
        award_amounts: award_amount_data(current_account, awards)
    }
  end

  def award_amount_data(current_account, awards)
    {
        my_project_coins: awards.sum {|a| a.account_id == current_account.id ? a.award_type.amount : 0 },
        total_coins_issued: awards.sum {|a| a.award_type.amount }
    }
  end

  def pie_chart_data(awards)
    awards.each_with_object({}) do |award, awards|
      awards[award.account_id] ||= {net_amount: 0}
      awards[award.account_id][:name] = award.account.slack_auth.display_name
      awards[award.account_id][:net_amount] += award.award_type.amount
    end.values
  end
end