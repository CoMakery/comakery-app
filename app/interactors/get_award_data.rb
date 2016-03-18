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
    end.values.sort_by{|award_data| -award_data[:net_amount]}
  end

  def contributions_by_day(awards_scope)
    recent_awards = awards_scope
                        .where("awards.created_at > ?", 30.days.ago)
                        .order("awards.created_at asc")

    contributor_auths = recent_awards.map { |award| award.account.slack_auth }.freeze
    empty_row_template = contributor_auths.each_with_object({}) do |contributor_auth, contributors|
      contributors[contributor_auth.display_name] = 0 if contributor_auth
    end.freeze

    awards_by_date = recent_awards.group_by{|a|a.created_at.to_date.iso8601}

    data = (0..30).each_with_object({}) do |days_ago, contribution_object_by_day|
      date = days_ago.days.ago.to_date
      date_string = date.iso8601
      contribution_object_by_day[date_string] = contributor_by_day_row(empty_row_template, date_string, awards_by_date[date_string])
    end

    data.values.sort_by { |contribution_object| contribution_object['date'] }
  end

  def contributor_by_day_row(empty_row_template, date_string, awards_on_day)
    row = {}
    row['date'] = date_string
    row = row.merge(empty_row_template.dup)

    (awards_on_day || []).each do |award|
      if award.account.slack_auth
        display_name = award.account.slack_auth.display_name
        row[display_name] ||=0
        row[display_name] += award.award_type.amount
      end
    end

    row
  end
end