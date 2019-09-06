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
    ProjectPolicy.new(@account, @project).show? || @account.accessable_awards.where(id: @award.id).exists?
  end

  def edit?
    (@award.issuer == @account) && @award.can_be_edited?
  end

  def assign?
    (@award.issuer == @account) && @award.can_be_assigned?
  end

  def start?
    @account && @account.accessable_awards.where(id: @award.id, status: 'ready').exists?
  end

  def create?
    return false unless @award.issuer == @account
    same_channel? && (@account == @project&.account || community?)
  end

  def review?
    (@award.issuer == @account) && (@award.status == 'submitted')
  end

  def submit?
    (@award.account == @account) && (@award.status == 'started')
  end

  def pay?
    (@award.issuer == @account) && (@award.status == 'accepted')
  end

  def same_channel?
    return true unless @award.channel
    return true if @award.channel.in?(@project.channels) && @award.issuer.teams.include?(@award.team)
    true
  end

  def community?
    @award&.award_type&.community_awardable? && @account != @award&.account
  end
end
