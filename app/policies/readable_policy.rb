class ReadablePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    raise Pundit::NotAuthorizedError if user.nil?

    user.admin?
  end

  def update?
    raise Pundit::NotAuthorizedError if user.nil?

    user.admin?
  end

  def destroy?
    raise Pundit::NotAuthorizedError if user.nil?

    user.admin?
  end
end
