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
    admin_or_owner?
  end

  def update?
    admin_or_owner?
  end

  def destroy?
    admin_or_owner?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope
      else
        user
      end
    end
  end

  def admin_or_owner?
    # user.admin? || record.id == user.id
    true
  end
end
