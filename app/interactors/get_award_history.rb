class GetAwardHistory
  include Interactor

  def call
    project = context.project

    awards = project.awards.includes(:account, :award_type).each_with_object({}) do |award, awards|
      awards[award.account_id] ||= {net_amount: 0}
      awards[award.account_id][:name] = award.account.slack_auth.display_name
      awards[award.account_id][:net_amount] += award.award_type.amount
    end

    context.award_data = awards.values
  end
end