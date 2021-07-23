class UserPolicy < PrivatePolicy
  def index?
    user.admin?
  end
end
