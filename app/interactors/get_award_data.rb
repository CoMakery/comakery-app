class GetAwardData
  include Interactor

  def call
    project = context.project
    authentication = context.authentication

    awards = project.awards.includes(:authentication, :award_type)
    awards_array = awards.dup.to_a

    context.award_data = {
        contributions: contributions_data(awards_array),
        contributions_summary: contributions_summary(project),
        contributions_summary_pie_chart: contributions_summary_pie_chart(awards_array),
        award_amounts: award_amount_data(authentication, awards_array),
        contributions_by_day: contributions_by_day(awards)
    }
  end

  def award_amount_data(authentication, awards)
    result = {total_coins_issued: awards.sum { |a| a.award_type.amount }}
    result[:my_project_coins] = authentication ? awards.sum { |a| a.authentication_id == authentication.id ? a.award_type.amount : 0 } : nil
    result
  end

  def contributions_summary(project)
    contributions = project.contributors_distinct.map do |contributor|
      {
          name: contributor.display_name,
          avatar: contributor.slack_icon,
          earned: contributor.total_awards_earned(project),
          paid: contributor.total_awards_paid(project),
          remaining: contributor.total_awards_remaining(project),
      }
    end

    highest_earned_first(contributions)
  end

  def highest_earned_first(contributions)
    contributions.sort { |a, b| b[:earned] <=> a[:earned] }
  end

  def contributions_data(awards)
    awards.each_with_object({}) do |award, awards|
      awards[award.authentication_id] ||= {net_amount: 0}
      awards[award.authentication_id][:name] ||= award.authentication.display_name || award.authentication.email
      awards[award.authentication_id][:net_amount] += award.award_type.amount
      awards[award.authentication_id][:avatar] ||= award.authentication.slack_icon
    end.values.sort_by{|award_data| -award_data[:net_amount]}
  end

  def contributions_summary_pie_chart(awards, fully_shown = 12)
    contributions = contributions_data(awards)
    summary = contributions[0...fully_shown]
    if contributions.size > fully_shown
      other = {name: 'Other'}
      other[:net_amount] = contributions[fully_shown..-1].sum { |award| award[:net_amount] }
      summary << other
    end
    summary
  end

  def contributions_by_day(awards_scope)
    history = 150
    recent_awards = awards_scope
                        .where("awards.created_at > ?", history.days.ago)
                        .order("awards.created_at asc")

    contributor_auths = recent_awards.map { |award| award.authentication }.freeze
    empty_row_template = contributor_auths.each_with_object({}) do |contributor_auth, contributors|
      # using display names is potentially problematic because these aren't unique, and also they could be a stale copy in our DB
      # from when the user last logged in
      contributors[contributor_auth.display_name] = 0 if contributor_auth
    end.freeze

    awards_by_date = recent_awards.group_by{|a|a.created_at.to_date.iso8601}

    start_days_ago = if recent_awards.present?
      award_age_days = (Time.now - recent_awards.first.created_at) / (60 * 60 * 24)
      [history, award_age_days].min
    else
      history
    end

    start_days_ago = [start_days_ago, 7].max  # at least 7 days

    data = (0..start_days_ago).each_with_object({}) do |days_ago, contribution_object_by_day|
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
      if award.authentication
        display_name = award.authentication.display_name
        row[display_name] ||=0
        row[display_name] += award.award_type.amount
      end
    end

    row
  end
end
