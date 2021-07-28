class ApplicationController < ActionController::Base
  include Pundit
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, with: :entity_not_found
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Pundit::NotDefinedError, with: :user_not_defined

  def render_bad_request(record)
    render json: { errors: record.errors }, status: :bad_request
  end

  def current_user
    User.find_by(token: request.headers['Authorization'])
  end

  private

  def entity_not_found
    controller = params['controller']
    render json: { errors: "#{controller[4..-2]} with such id does not exist" }, status: :not_found
  end

  def user_not_defined
    render json: { errors: { token: ['is invalid'] } }, status: :unauthorized
  end

  def user_not_authorized
    render json: { errors: { resource: ['is forbidden'] } }, status: :forbidden
  end
end
