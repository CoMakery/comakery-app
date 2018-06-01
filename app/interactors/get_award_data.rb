class GetAwardData
  include Interactor

  def call
    project = context.project
    awards = project.awards.includes(:account, :award_type)
    context.award_data = {
      contributions_by_day: contributions_by_day(awards)
    }
  end

  def contributions_by_day(awards_scope)
    history = 150
    recent_awards = awards_scope
                    .where('awards.created_at > ?', history.days.ago)
                    .order('awards.created_at asc')

    accounts = recent_awards.map(&:account).freeze
    empty_row_template = accounts.each_with_object({}) do |account, contributors|
      # using display names is potentially problematic because these aren't unique, and also they could be a stale copy in our DB
      # from when the user last logged in
      contributors[account.decorate.name] = 0 if account
    end.freeze

    awards_by_date = recent_awards.group_by { |a| a.created_at.to_date.iso8601 }

    start_days_ago = if recent_awards.any?
      award_age_days = (Time.now - recent_awards.first.created_at) / (60 * 60 * 24)
      [history, award_age_days].min
    else
      history
    end

    start_days_ago = [start_days_ago, 7].max # at least 7 days

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
      next unless award.account
      name = award.account.decorate.name
      row[name] ||= 0
      row[name] += award.total_amount
    end

    row
  end
end
