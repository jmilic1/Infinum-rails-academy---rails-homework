module Api
  class UsersController < ApplicationController

    # rubocop:disable Layout/LineLength
    def index
      if request.headers['x_api_serializer_root'] == '0'
        render json: UserSerializer.render_as_hash(User.all, view: :extended), status: :ok
      else
        render json: { users: UserSerializer.render_as_hash(User.all, view: :extended) }, status: :ok
      end
    end

    def create
      user_values = user_params
      return render json: { errors: { credentials: ['are invalid'] } }, status: :bad_request if user_values['password'].nil? ||
                                                                                                user_values['password'].length.zero?

      user = User.new(user_params)

      if user.save
        render json: { user: UserSerializer.render_as_hash(user, view: :extended) }, status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end
    # rubocop:enable Layout/LineLength

    def show
      user = User.find(params[:id])

      if user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :bad_request
      end

      # rubocop:disable Layout/LineLength
      if request.headers['x_api_serializer'] == 'json_api'
        render json: { user:  JsonApi::UserSerializer.new(user).serializable_hash.to_json }, status: :ok
      else
        render json: { user: UserSerializer.render_as_hash(user, view: :extended) }, status: :ok
      end
      # rubocop:enable Layout/LineLength
    end

    # rubocop:disable Metrics/MethodLength
    def update
      user = User.find(params[:id])

      if user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :bad_request
      end

      # rubocop:disable Layout/LineLength
      user_values = user_params
      return render json: { errors: 'New password cannot be nil/empty string' }, status: :bad_request if !user_values['password'].nil? &&
                                                                                                         user_values['password'].length.zero?
      # rubocop:enable Layout/LineLength

      if user.update(user_values)
        render json: { user: UserSerializer.render_as_hash(user, view: :extended) }, status: :ok
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end
    # rubocop:enable Metrics/MethodLength

    def destroy
      user = User.find(params[:id])

      if user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :bad_request
      end

      if user.destroy
        render json: {}, status: :no_content
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end
  end
end
