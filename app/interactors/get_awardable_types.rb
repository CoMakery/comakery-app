class GetAwardableTypes
  include Interactor

  def call
    account = context.account
    project = context.project

    awardable_types = award_types
    awardable_types = awardable_types.active if awardable_types.present?
    can_award = own_project?(account, project) ||
                (awardable_types.any?(&:community_awardable?) && belong_to_project?(account, project))

    context.can_award = can_award
    context.awardable_types = awardable_types
  end

  private

  def award_types
    if !context.account
      AwardType.none
    elsif own_project?(context.account, context.project)
      context.project.award_types
    elsif belong_to_project?(context.account, context.project)
      context.project.community_award_types
    else
      AwardType.none
    end
  end

  def own_project?(account, project)
    project&.account == account
  end

  def belong_to_project?(account, project)
    account.team_projects.include?(project)
  end
end
