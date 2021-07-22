module Api
  class UsersController < ApplicationController
    def index
      render json: { user: UserSerializer.render(User.all) }, status: :ok
    end

    def create
      user = User.new(user_params)

      if user.save
        render json: { user: UserSerializer.render(user) }, status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def show
      user = User.find(params[:id])

      if user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :bad_request
      end

      # rubocop:disable Layout/LineLength
      if request.headers['x_api_serializer'] == 'json_api'
        render json: { user:  JsonApi::UserSerializer.new(user).serializable_hash.to_json }, status: :ok
      else
        render json: { user: UserSerializer.render(user) }, status: :ok
      end
      # rubocop:enable Layout/LineLength
    end

    def update
      user = User.find(params[:id])

      if user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :bad_request
      end

      if user.update(user_params)
        render json: {}, status: :no_content
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

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
      params.require(:user).permit(:first_name, :last_name, :email)
    end
  end
end
