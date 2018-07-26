class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.none
    end
  end

  def show?
    account.present?
  end

  def new?
    account.present?
  end

  def create?
    account.present?
  end

  def edit?
    account.present?
  end

  def update?
    account.present?
  end
end
