class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.admin?
  end

  def show?
    user.admin? || record.id == user.id
  end

  def update?
    user.admin? || record.id == user.id
  end

  def destroy?
    user.admin? || record.id == user.id
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        user
        # scope.where(id: user.id)
      end
    end
  end
end
