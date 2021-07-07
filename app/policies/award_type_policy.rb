class AwardTypePolicy < ApplicationPolicy
  attr_reader :account, :award_type, :mission

  def initialize(account, award_type)
    @account = account
    @award_type = award_type
    @mission = @award_type.project.mission
  end

  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, project, scope)
      @account = account
      @scope = scope
      @project_editable = ProjectPolicy.new(account, project).edit?
    end

    def resolve
      if @project_editable
        scope.all
      else
        scope.where.not(state: :draft)
      end
    end
  end

  def index?
    return mission.project_awards_visible? if mission.present? && mission.whitelabel?

    true
  end
end
