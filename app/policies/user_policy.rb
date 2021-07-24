class UserPolicy < PrivatePolicy
  def index?
    raise Pundit::NotAuthorizedError if user.nil?

    user.admin?
  end
end
