class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, with: :entity_not_found

  def render_bad_request(record)
    render json: { errors: record.errors }, status: :bad_request
  end

  private

  def entity_not_found
    controller = params['controller']
    render json: { errors: "#{controller[4..-2]} with such id does not exist" }, status: :not_found
  end
end
