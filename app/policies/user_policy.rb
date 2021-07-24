class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    raise Pundit::NotAuthorizedError if user.nil?

    user.admin?
  end

  def show?
    raise Pundit::NotDefinedError if user.nil?
    raise Pundit::NotAuthorizedError if !user.admin? && record.id != user.id

    user.admin? || user.public?
  end

  def update?
    raise Pundit::NotAuthorizedError if user.nil?
    raise Pundit::NotAuthorizedError if !user.admin? && record.id != user.id

    user.admin? || user.public?
  end

  def destroy?
    raise Pundit::NotAuthorizedError if user.nil?
    raise Pundit::NotAuthorizedError if !user.admin? && record.id != user.id

    user.admin? || user.public?
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
        scope.where(id: user.id)
      end
    end
  end
end
