class BookingPolicy < PrivatePolicy
  def index?
    user.admin? || user.public?
  end
end
