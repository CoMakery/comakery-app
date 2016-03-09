class GetAwardData
  include Interactor

  def call
    project = context.project
    current_account = context.current_account

    awards = project.awards.includes(:account, :award_type)
    awards_array = awards.dup.to_a

    context.award_data = {
        contributions: contributions_data(awards_array),
        award_amounts: award_amount_data(current_account, awards_array),
        contributions_by_day: contributions_by_day(awards)
    }
  end

  def contributions_by_day(awards)
    data = (1..30).each_with_object({}) do |days_ago, contribution_object_by_day|
      date_string = days_ago.days.ago.strftime("%Y%m%d")
      contribution_object_by_day[date_string] = {date: date_string, value: 0}
    end

    awards.where("awards.created_at > ?", 30.days.ago).group_by { |award| award.created_at.to_date }.each do |(created_date, awards)|
      date_string = created_date.strftime("%Y%m%d")
      data[date_string] = {date: date_string, value: awards.sum { |award| award.award_type.amount }}
    end

    data.values.sort_by{|contribution_object| contribution_object[:date]}
  end

  def award_amount_data(current_account, awards)
    result = {total_coins_issued: awards.sum { |a| a.award_type.amount }}
    result[:my_project_coins] = current_account ? awards.sum { |a| a.account_id == current_account.id ? a.award_type.amount : 0 } : nil
    result
  end

  def contributions_data(awards)
    awards.each_with_object({}) do |award, awards|
      awards[award.account_id] ||= {net_amount: 0}
      awards[award.account_id][:name] = award.account.slack_auth&.display_name || award.account.email
      awards[award.account_id][:net_amount] += award.award_type.amount
    end.values
  end
end