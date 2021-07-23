class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include Pundit

  def current_user
    User.find_by(token: request.headers['Authorization'])
  end
end
