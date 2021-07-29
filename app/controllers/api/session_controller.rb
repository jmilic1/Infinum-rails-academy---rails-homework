module Api
  class SessionController < ApplicationController
    def create
      credentials = session_params

      user = User.find_by(email: credentials['email'])
      return render_login_error if user.nil?

      user = user.authenticate(credentials['password'])
      return render_login_error unless user

      render json: { session: { user: UserSerializer.render_as_hash(user, view: :extended),
                                token: user.token } },
             status: :created
    end

    def destroy
      token = request.headers['Authorization']

      user = User.find_by(token: token)
      return render_logout_error if user.nil?

      user.regenerate_token

      head :no_content
    end

    private

    def session_params
      params.require(:session).permit(:email, :password)
    end

    def render_login_error
      render json: { errors: { credentials: ['are invalid'] } }, status: :bad_request
    end

    def render_logout_error
      render json: { errors: { token: ['is invalid'] } }, status: :unauthorized
    end
  end
end
