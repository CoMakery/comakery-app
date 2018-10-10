class GetContributorData
  include Interactor
  def call
    project = context.project
    awards = project.awards.includes(:account, :award_type)
    awards_array = awards.dup.to_a

    context.award_data = {
      contributions_summary_pie_chart: contributions_summary_pie_chart(awards_array)
    }
  end

  def contributions_data(awards)
    awards.each_with_object({}) do |award, a_hash|
      award = award.decorate
      a_hash[award.account_id] ||= { net_amount: 0 }
      a_hash[award.account_id][:name] ||= award.recipient_display_name
      a_hash[award.account_id][:net_amount] += award.amount_to_send
    end.values
  end

  def contributions_summary_pie_chart(awards)
    contributions = contributions_data(awards)
    total = contributions.sum { |award| award[:net_amount] }
    summary = contributions.reject { |c| c[:net_amount] < total.to_f / 100 }
    others = contributions.reject { |c| c[:net_amount] >= total.to_f / 100 }

    if others.any?
      other = { name: 'Other' }
      other[:net_amount] = others.sum { |award| award[:net_amount] }
      summary << other
    end
    summary
  end
end
