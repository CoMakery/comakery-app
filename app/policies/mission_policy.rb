class MissionPolicy < ApplicationPolicy
  attr_reader :account, :mission

  def initialize(account, mission)
    @account = account
    @mission = mission
  end

  def new?
    @account.comakery_admin?
  end

  alias index? new?
  alias create? new?
  alias edit? new?
  alias update? new?
  alias destroy? new?
end
