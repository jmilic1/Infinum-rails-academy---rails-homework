module Api
  class SessionController < ApplicationController
    def create
      credentials = session_params

      user = User.find_by(email: credentials['email'])
      return render_error if user.nil?

      user = user.authenticate(credentials['password'])

      return render_error unless user

      render json: { session: { user: UserSerializer.render_as_hash(user, view: :extended),
                                token: user.token } },
             status: :ok
    end

    def delete
      token = request.headers['Authorization']
      return render_error if token.nil?

      user = User.find_by(token: token)
      return render_error if user.nil?

      user.regenerate_token

      render json: {}, status: :no_content
    end

    private

    def session_params
      params.require(:session).permit(:email, :password)
    end

    def render_error
      render json: { errors: { credentials: ['are invalid'] } }, status: :bad_request
    end
  end
end
