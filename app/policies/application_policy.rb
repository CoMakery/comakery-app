class ApplicationPolicy
  attr_reader :account, :record

  def initialize(account, record)
    @account = account
    @record = record
  end

  def scope
    Pundit.policy_scope!(account, record.class)
  end

  class Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
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
