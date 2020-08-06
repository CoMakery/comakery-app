class AwardPolicy < ApplicationPolicy
  attr_reader :account, :award

  class Scope < Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope = scope
    end

    def resolve
      if @account
        @account.accessable_awards
      else
        scope.none
      end
    end
  end

  def initialize(account, award)
    @account = account
    @award = award
    @project = @award.project
  end

  def show?
    ProjectPolicy.new(@account, @project).show? || (@account && @account.related_awards.where(id: @award.id).exists?)
  end

  def edit?
    project_editable? && @award.can_be_edited?
  end

  def assign?
    project_editable? && @award.can_be_assigned?
  end

  def start?
    @award.status.in?(%w[ready invite_ready]) && (@account&.related_awards&.where(id: @award.id)&.exists? || @account&.accessable_awards&.where(id: @award.id)&.exists?)
  end

  def create?
    project_editable?
  end

  def review?
    project_editable? && (@award.status == 'submitted')
  end

  def submit?
    (@award.account == @account) && (@award.status == 'started')
  end

  def pay?
    project_editable? && (@award.status == 'accepted')
  end

  def cancel?
    cancel_by_contributor? || cancel_by_admin?
  end

  def cancel_by_contributor?
    submit?
  end

  def cancel_by_admin?
    pay? || assign?
  end

  def project_editable?
    ProjectPolicy.new(@account, @project).edit?
  end

  def project_team_member?
    ProjectPolicy.new(@account, @project).team_member?
  end
end
