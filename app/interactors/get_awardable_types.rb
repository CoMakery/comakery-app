class GetAwardableTypes
  include Interactor

  # rubocop:disable Metrics/CyclomaticComplexity
  def call
    current_account = context.current_account
    project = context.project

    awardable_types = if !current_account
      []
    elsif own_project?(current_account, project)
      project.award_types
    elsif belong_to_project?(current_account, project)
      project.community_award_types
    else
      []
    end
    awardable_types = awardable_types.active if awardable_types.present?
    can_award = own_project?(current_account, project) ||
                (awardable_types.any?(&:community_awardable?) && belong_to_project?(current_account, project))

    context.can_award = can_award
    context.awardable_types = awardable_types
  end

  private

  def own_project?(account, project)
    belong_to_project?(account, project) && project&.owner_account == account
  end

  def belong_to_project?(account, project)
    project&.slack_team_id == account&.slack_auth&.slack_team_id
  end
end
