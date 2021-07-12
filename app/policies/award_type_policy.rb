class AwardTypePolicy < ApplicationPolicy
  attr_reader :account, :award_type

  def initialize(account, award_type)
    @account = account
    @award_type = award_type
  end

  class Scope < Scope
    attr_reader :account, :project, :whitelabel_mission, :scope

    def initialize(account, project, whitelabel_mission, scope)
      @account = account
      @project = project
      @whitelabel_mission = whitelabel_mission
      @scope = scope
    end

    def resolve
      if project_policy.edit?
        scope.all
      else
        scope.where.not(state: :draft)
      end
    end

    def index?
      if whitelabel_mission.present?
        (project_policy.show? || project_policy.unlisted?) && whitelabel_mission.project_awards_visible?
      else
        project_policy.show? || project_policy.unlisted?
      end
    end

    private

      def project_policy
        @project_policy ||= ProjectPolicy.new(account, project)
      end
  end
end
