class PrivatePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    raise Pundit::NotAuthorizedError if user.nil?

    user.admin? || user.public?
  end

  def update?
    raise Pundit::NotAuthorizedError if user.nil?

    user.admin? || user.public?
  end

  def destroy?
    raise Pundit::NotAuthorizedError if user.nil?

    user.admin? || user.public?
  end
end
