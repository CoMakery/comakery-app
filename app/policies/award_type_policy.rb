class AwardTypePolicy < ApplicationPolicy
  attr_reader :account, :award_type

  def initialize(account, award_type)
    @account = account
    @award_type = award_type
  end

  class Scope < Scope
    attr_reader :account, :project, :scope

    def initialize(account, project, scope)
      @account = account
      @project = project
      @scope = scope
    end

    def resolve
      if project_policy.edit?
        scope.all
      else
        scope.where.not(state: :draft)
      end
    end

    private

      def project_policy
        @project_policy ||= ProjectPolicy.new(account, project)
      end
  end
end
