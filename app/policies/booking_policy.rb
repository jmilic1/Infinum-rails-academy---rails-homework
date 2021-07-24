class BookingPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    raise Pundit::NotDefinedError if user.nil?

    user.admin? || user.public?
  end

  def show?
    raise Pundit::NotDefinedError if user.nil?
    raise Pundit::NotAuthorizedError if !user.admin? && record.user_id != user.id

    user.admin? || user.public?
  end

  def update?
    raise Pundit::NotAuthorizedError if user.nil?
    raise Pundit::NotAuthorizedError if !user.admin? && record.user_id != user.id

    user.admin? || user.public?
  end

  def destroy?
    raise Pundit::NotAuthorizedError if user.nil?
    raise Pundit::NotAuthorizedError if !user.admin? && record.user_id != user.id

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
        scope.where(user_id: user.id)
      end
    end
  end
end
