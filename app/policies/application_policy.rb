class ApplicationPolicy
  attr_reader :account, :record

  def initialize(account, record)
    @account = account
    @record = record
  end

  class Scope
    attr_reader :account, :scope
  end

  def new?
    account.present?
  end

  def create?
    account.present?
  end
end
