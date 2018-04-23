class GetAwardData
  include Interactor
  include ApplicationHelper
  include Refile::AttachmentHelper
  include ActionView::Helpers
  def call
    project = context.project
    account = context.account

    awards = project.awards.includes(:account, :award_type)
    awards_array = awards.dup.to_a

    context.award_data = {
      contributions: contributions_data(awards_array),
      contributions_summary: contributions_summary(project),
      contributions_summary_pie_chart: contributions_summary_pie_chart(awards_array),
      award_amounts: award_amount_data(account, awards_array),
      contributions_by_day: contributions_by_day(awards)
    }
  end

  def award_amount_data(account, awards)
    result = { total_tokens_issued: awards.sum(&:total_amount) }
    result[:my_project_tokens] = account ? awards.sum { |a| a.account_id == account.id ? a.total_amount : 0 } : nil
    result
  end

  def avatar(account)
    url = account_image_url(account, 34)
    url = '/assets/default_account_image.jpg' if url == '/default_account_image.jpg'
    url
  end

  def contributions_summary(project)
    contributions = project.contributors_distinct
    highest_earned_first(contributions, project)
  end

  def highest_earned_first(contributions, project)
    contributions.sort { |a, b| b.total_awards_earned(project) <=> a.total_awards_earned(project) }
  end

  def contributions_data(awards)
    awards.each_with_object({}) do |award, a_hash|
      a_hash[award.account_id] ||= { net_amount: 0 }
      a_hash[award.account_id][:name] ||= award.recipient_display_name
      a_hash[award.account_id][:net_amount] += award.total_amount
      a_hash[award.account_id][:avatar] ||= avatar(award.account) if award.account
    end.values.sort_by { |award_data| -award_data[:net_amount] }
  end

  def contributions_summary_pie_chart(awards, fully_shown = 12)
    contributions = contributions_data(awards)
    summary = contributions[0...fully_shown]
    if contributions.size > fully_shown
      other = { name: 'Other' }
      other[:net_amount] = contributions[fully_shown..-1].sum { |award| award[:net_amount] }
      summary << other
    end
    summary
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
      contributors[account.name] = 0 if account
    end.freeze

    awards_by_date = recent_awards.group_by { |a| a.created_at.to_date.iso8601 }

    start_days_ago = if recent_awards.present?
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
      name = award.account.name
      row[name] ||= 0
      row[name] += award.total_amount
    end

    row
  end
end
