class BookingPolicy < PrivatePolicy
  def index?
    raise Pundit::NotDefinedError if user.nil?

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
