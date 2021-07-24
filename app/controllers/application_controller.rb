class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include Pundit

  def current_user
    User.find_by(token: request.headers['Authorization'])
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Pundit::NotDefinedError, with: :user_not_defined

  private

  def user_not_defined
    render json: { errors: { token: ['is invalid'] } }, status: :unauthorized
  end

  def user_not_authorized
    render json: { errors: { resource: ['is forbidden'] } }, status: :forbidden
  end
end
