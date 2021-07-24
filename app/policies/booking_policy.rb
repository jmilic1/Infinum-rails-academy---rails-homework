class BookingPolicy < PrivatePolicy
  def index?
    raise Pundit::NotAuthorizedError if user.nil?

    user.admin? || user.public?
  end
end
