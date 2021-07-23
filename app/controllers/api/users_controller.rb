module Api
  class UsersController < ApplicationController
    def index
      if request.headers['X_API_SERIALIZER_ROOT'] == '0'
        render json: UserSerializer.render(User.all, view: :extended), status: :ok
      else
        render json: UserSerializer.render(User.all, view: :extended, root: :users), status: :ok
      end
    end

    def create
      user = User.new(user_params)

      if user.save
        render json: UserSerializer.render(user, view: :extended, root: :user), status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def show
      user = User.find_by(id: params[:id])
      if user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :not_found
      end

      if request.headers['X_API_SERIALIZER'] == 'json_api'
        render json: { user:  JsonApi::UserSerializer.new(user).serializable_hash.to_json },
               status: :ok
      else
        render json: UserSerializer.render(user, view: :extended, root: :user), status: :ok
      end
    end

    def update
      user = User.find_by(id: params[:id])
      if user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :not_found
      end

      if user.update(user_params)
        render json: UserSerializer.render(user, view: :extended, root: :user), status: :ok
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def destroy
      user = User.find_by(id: params[:id])
      if user.nil?
        return render json: { errors: 'User with such id does not exist' }, status: :not_found
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
